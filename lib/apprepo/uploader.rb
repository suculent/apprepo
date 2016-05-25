#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'net/ssh'
require 'net/sftp'

require 'fastlane_core'
require 'fastlane_core/languages'

require_relative 'options'

module AppRepo
  # rubocop:disable Metrics/ClassLength

  # Responsible for performing the SFTP operation
  class Uploader
    attr_accessor :options

    #
    # These want to be an input parameters:
    #

    attr_accessor :host
    attr_accessor :user
    attr_accessor :password
    attr_accessor :rsa_keypath
    attr_accessor :ipa_path
    attr_accessor :manifest_path
    attr_accessor :appcode

    @ssh_session = nil

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize(options)
      FastlaneCore::UI.message('Initializing...')

      puts options.join(',')

      puts options[:host]
      puts options[:user]
      puts options[:password]
      puts options[:rsa_keypath]
      puts options[:ipa_path]
      puts options[:manifest_path]
      puts options[:appcode]

      self.host = 'repo.teacloud.net'
      self.user = 'circle'
      self.password = 'circle'
      self.rsa_keypath = '../assets/circle.key'
      self.ipa_path = '../sampleapp.ipa'
      self.manifest_path = '../assets/example_manifest.json'
      self.appcode = 'APPREPO'

      self.options = options unless options.nil?

      # AppRepo::Uploader.new.run!
      # FastlaneCore::PrintTable.print_values(config: nil , hide_keys: [:app],
      # mask_keys: ['app_review_information.demo_password'],
      # title: "deliver #{AppRepo::VERSION} Summary") # options
    end

    #
    # Upload IPA & manifest
    #

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def upload
      # Login & Upload IPA with metadata using RSA key or username/password
      rsa_key = load_rsa_key(rsa_keypath)
      if rsa_key?
        FastlaneCore::UI.message('Logging in with RSA key...')
        Net::SSH.start(host, user, key_data: rsa_key, keys_only: true) do |ssh|
          self.ssh_session = ssh
          FastlaneCore::UI.message('Uploading IPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      else
        FastlaneCore::UI.message('Logging in...')
        Net::SSH.start(host, user, password: password) do |ssh|
          self.ssh_session = ssh
          FastlaneCore::UI.message('Logged in, uploading IPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      end
    end

    #
    # Download metadata only
    #

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def download_metadata
      rsa_key = load_rsa_key(rsa_keypath)
      if rsa_key?
        FastlaneCore::UI.message('Logging in with RSA key...')
        Net::SSH.start(host, user, key_data: rsa_key, keys_only: true) do |ssh|
          self.ssh_session = ssh
          FastlaneCore::UI.message('Uploading UPA & Manifest...')
          ssh_sftp_download(ssh, manifest_path)
        end
      else
        FastlaneCore::UI.message('Logging in...')
        Net::SSH.start(host, user, password: password) do |ssh|
          self.ssh_session = ssh
          FastlaneCore::UI.message('Logged in, uploading UPA & Manifest...')
          ssh_sftp_download(ssh, manifest_path)
        end
      end
    end

    private

    def ssh_sftp_download(ssh, local_ipa_path, _manifest_path)
      ssh.sftp.connect do |sftp|
        break unless check_ipa(local_ipa_path)
        FastlaneCore::UI.message('[Downloading] Will start...')
        manifest = download_manifest(sftp)
        puts manifest.join(',')
      end
    end

    def ssh_sftp_upload(ssh, local_ipa_path, manifest_path)
      ssh.sftp.connect do |sftp|
        break unless check_ipa(local_ipa_path)
        check_appcode(sftp, appcode)
        path = remote_path(appcode)
        manifest = download_manifest(sftp, remote)
        bump_ipa(sftp, local_ipa_path)

        FastlaneCore::UI.message('[Uploading] Will start...')
        upload_ipa(sftp, local_ipa_path, remote_ipa_path)
        upload_manifest(sftp, manifest_path, remote_manifest_path)

        # Lists the entries in a directory for verification
        sftp.dir.foreach(path) do |entry|
          FastlaneCore::UI.message(entry.longname)
        end
      end
    end

    # Check IPA existence locally
    #
    # @param local_ipa_path
    def check_ipa(local_ipa_path)
      if File.exist?(local_ipa_path)
        FastlaneCore::UI.message('IPA found at ' + local_ipa_path)
        return true
      else
        FastlaneCore::UI.message('IPA at given path does not exist!')
        return false
      end
    end

    # Private methods - Remote Operations

    # Checks/creates remote APPCODE directory
    # @param sftp
    # @param [String] appcode
    def check_appcode(sftp, appcode)
      path = remote_path(appcode)
      FastlaneCore::UI.message('Checking APPCODE at: ' + path)
      remote_mkdir(sftp, path)
    end

    # Checks/renames remote IPA
    #
    # @params sftp
    # @params [String] local_ipa_path
    def bump_ipa(sftp, local)
      remote = get_remote_ipa_path(local)
      FastlaneCore::UI.message('Checking remote IPA')
      begin
        sftp.stat!(remote) do |response|
          if response.ok?
            FastlaneCore::UI.message('Bumping existing IPA')
            begin
              sftp.remove(remote + '.bak') # may fail if not existent
              FastlaneCore::UI.message('Removed ' + remote + '.bak')
            rescue
              sftp.rename!(remote, remote + '.bak')
              FastlaneCore::UI.message('Bumped to ' + remote + '.bak')
            end
          end
        end
      rescue
        FastlaneCore::UI.message('No previous IPA found.')
      end
    end

    # Downloads remote manifest
    #
    # @params sftp
    # @params [String] remote_path
    def download_manifest(sftp)
      FastlaneCore::UI.message('Checking remote Manifest')
      remote_manifest_path = remote_path + '/manifest.json'
      json = ''
      begin
        sftp.stat!(remote_manifest_path) do |response|
          if response.ok?
            FastlaneCore::UI.message('Reading existing Manifest')
            sftp.file.open(remote_manifest_path, 'w') do |remote_manifest|
              UI.message('Opened file from sftp')
              manifest = remote_manifest.gets
              json = JSON.parse(manifest)
              puts '********************************************************'
              puts json
              puts '********************************************************'
            end
          end
        end
      rescue
        FastlaneCore::UI.message('No previous Manifest found')
      end
      json
    end

    # Upload current IPA
    #
    # @param sftp
    # @param [String] local_ipa_path
    # @param [String] remote_ipa_path
    def upload_ipa(sftp, local_ipa_path, remote_ipa_path)
      path = File.dirname(__FILE__) + '/' + local_ipa_path
      msg = '[Uploading IPA] ' + path + ' to ' + remote_ipa_path
      FastlaneCore::UI.message(msg)
      sftp.upload!(path, remote_ipa_path)
    end

    # Upload current manifest.json
    #
    # @param sftp
    # @param [String] manifest_path
    # @param [String] remote_manifest_path
    def upload_manifest(sftp, local_path, remote_path)
      msg = '[Uploading Manifest] ' + local_path + ' to ' + remote_path
      FastlaneCore::UI.message(msg)
      sftp.upload!(local_path, remote_path)
    end

    def get_remote_ipa_path(ipa_path)
      path = remote_path + File.basename(ipa_path)
      FastlaneCore::UI.message('remote_ipa_path: ' + path)
      path
    end

    def remote_path(appcode)
      path = generate_remote_path + appcode + '/'
      FastlaneCore::UI.message('remote_path: ' + path)
      path
    end

    def generate_remote_path
      path = '/home/' + user + '/repo/apps/'
      FastlaneCore::UI.message('generate_remote_path: ' + path)
      path
    end

    def remote_mkdir(sftp, remote_path)
      sftp.mkdir remote_path
    rescue Net::SFTP::StatusException => e
      raise if e.code != 11
      msg = 'Remote dir ' + remote_path + ' exists.'
      FastlaneCore::UI.message(msg)
    end

    # Private methods - Local Operations

    def load_rsa_key(rsa_keypath)
      File.open(File.dirname(__FILE__) + '/' + rsa_keypath, 'r') do |file|
        rsa_key = [file.read]
        msg = 'Successfully loaded RSA key...'
        FastlaneCore::UI.message(msg) unless rsa_key.nil?
        return rsa_key
      end
    end
  end
end

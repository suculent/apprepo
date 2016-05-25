#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'net/ssh'
require 'net/sftp'

require 'fastlane'
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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize(options)
      self.options = options unless options.nil?
      self.host = options[:repo_url] # 'repo.teacloud.net'
      self.user = options[:repo_user]
      self.password = options[:repo_password]
      self.rsa_keypath = options[:repo_key] # '../assets/circle.key'
      self.ipa_path = options[:ipa] # '../sampleapp.ipa'
      self.manifest_path = options[:manifest_path] # '../assets/example_manifest.json'
      self.appcode = options[:appcode]

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
      success = false
      if !rsa_key.nil?
        FastlaneCore::UI.message('Logging in with RSA key...')
        Net::SSH.start(host, user, key_data: rsa_key, keys_only: true) do |ssh|
          FastlaneCore::UI.message('Uploading IPA & Manifest...')
          success = ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      else
        FastlaneCore::UI.message('Logging in...')
        Net::SSH.start(host, user, password: password) do |ssh|
          self.ssh_session = ssh
          FastlaneCore::UI.message('Logged in, uploading IPA & Manifest...')
          success = ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      end
      success
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
        puts '********************************************************'
        puts JSON.pretty_generate(manifest)
        puts '********************************************************'
      end
    end

    def ssh_sftp_upload(ssh, local_ipa_path, manifest_path)
      ssh.sftp.connect do |sftp|
        break unless check_ipa(local_ipa_path)
        check_appcode(sftp, appcode)
        path = remote_path(appcode)
        manifest = download_manifest(sftp)
        puts JSON.pretty_generate(manifest) unless manifest.nil?
        bump_ipa(sftp, local_ipa_path, appcode)
        remote_ipa_path = get_remote_ipa_path(local_ipa_path, appcode)
        upload_ipa(sftp, local_ipa_path, remote_ipa_path)
        upload_manifest(sftp, manifest_path, remote_manifest_path(appcode))
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
        FastlaneCore::UI.important('IPA found at ' + local_ipa_path)
        return true
      else
        FastlaneCore::UI.verbose('IPA at given path does not exist yet.')
        return false
      end
    end

    # Private methods - Remote Operations

    # Checks/creates remote APPCODE directory
    # @param sftp
    # @param [String] appcode
    def check_appcode(sftp, appcode)
      path = remote_path(appcode)
      FastlaneCore::UI.message('Checking APPCODE')
      remote_mkdir(sftp, path)
    end

    # Checks/renames remote IPA
    #
    # @params sftp
    # @params [String] local_ipa_path
    def bump_ipa(sftp, local, appcode)
      remote = get_remote_ipa_path(local, appcode)
      FastlaneCore::UI.message('Checking remote IPA')
      begin
        sftp.stat!(remote) do |response|
          if response.ok?
            begin
              sftp.rename!(remote, remote + '.bak')
            rescue
              begin
                sftp.remove(remote + '.bak') # may fail if not existent
                FastlaneCore::UI.message('Removed ' + remote + '.bak')
              rescue
                sftp.rename!(remote, remote + '.bak')
                FastlaneCore::UI.message('Bumped to ' + remote + '.bak')
              end
            end
          end
        end
      rescue
        FastlaneCore::UI.message('No previous IPA found.')
      end
    end

    # Downloads remote manifest, self.appcode required by options.
    #
    # @param sftp
    # @param [String] remote_path
    # @returns [JSON] json or nil
    def download_manifest(sftp)
      FastlaneCore::UI.message('Checking remote Manifest')
      json = nil
      remote_manifest_path = remote_manifest_path(appcode)
      begin
        sftp.stat!(remote_manifest_path) do |response|
          if response.ok?
            FastlaneCore::UI.success('Loading remote manifest:')
            manifest = sftp.download!(remote_manifest_path)
            json = JSON.parse(manifest)
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
      msg = '[Uploading IPA] ' + local_ipa_path + ' to ' + remote_ipa_path
      FastlaneCore::UI.message(msg)
      result = sftp.upload!(local_ipa_path, remote_ipa_path) do |event, _uploader, *_args|
        case event
        when :open then
          putc '.'
        when :put then
          putc '.'
          $stdout.flush
        when :close then
          puts "\n"
        when :finish then
          FastlaneCore::UI.success('Upload successful!')
        end
      end
    end

    # Upload current manifest.json
    #
    # @param sftp
    # @param [String] manifest_path
    # @param [String] remote_manifest_path
    def upload_manifest(sftp, local_path, remote_path)
      msg = '[Uploading Manifest] ' + local_path + ' to ' + remote_path
      FastlaneCore::UI.message(msg)
      result = sftp.upload!(local_path, remote_path) do |event, _uploader, *_args|
        case event
        when :finish then
          FastlaneCore::UI.success('Upload successful!')
        end
      end
    end

    def get_remote_ipa_path(local_ipa_path, appcode)
      remote_path(appcode) + File.basename(local_ipa_path)
    end

    def remote_path(appcode)
      generate_remote_path + appcode + '/'
    end

    def remote_manifest_path(appcode)
      remote_manifest_path = remote_path(appcode) + 'manifest.json'
    end

    def generate_remote_path
      '/home/' + user + '/repo/apps/'
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
      File.open(rsa_keypath, 'r') do |file|
        rsa_key = nil
        rsa_key = [file.read]
        if !rsa_key.nil?
          FastlaneCore::UI.success('Successfully loaded RSA key...')
        else
          FastlaneCore::UI.user_error!('Failed to load RSA key...')
        end
        rsa_key
      end
    end
  end
end

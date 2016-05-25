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

    def initialize(options)
      Fastlane::UI.message('[Uploader] Initializing...')
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
    # Main
    #

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def run
      # Login & Upload IPA with metadata using RSA key or username/password
      rsa_key = load_rsa_key(rsa_keypath)
      if rsa_key?
        Fastlane::UI.message('[Uploader] Logging in with RSA key...')
        Net::SSH.start(host, user, key_data: rsa_key, keys_only: true) do |ssh|
          Fastlane::UI.message('[Uploader] Uploading UPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      else
        Fastlane::UI.message('[Uploader] Logging in...')
        Net::SSH.start(host, user, password: password) do |ssh|
          Fastlane::UI.message('Logged in, uploading UPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      end
    end

    def ssh_sftp_upload(ssh, local_ipa_path, manifest_path)
      ssh.sftp.connect do |sftp|
        # Check IPA existence locally
        if File.exist?(local_ipa_path)
          Fastlane::UI.message('[Uploader] IPA found at ' + local_ipa_path)
        else
          Fastlane::UI.message('[Uploader] IPA at given path does not exist!')
          break
        end

        #
        # Check/create remote APPCODE directory
        # @params sftp, appcode;
        # @callees remote_path()
        #

        remote_path = generate_remote_path + appcode
        Fastlane::UI.message('[Uploader] Checking APPCODE at: ' + remote_path)
        remote_mkdir(sftp, remote_path)

        #
        # Check/fetch remote MANIFEST
        # @params sftp, appcode;
        # @callees remote_path()
        #

        remote_manifest_path = remote_path + '/manifest.json'

        Fastlane::UI.message('[Uploader] Checking remote Manifest.')
        begin
          sftp.stat!(remote_manifest_path) do |response|
            if response.ok?
              Fastlane::UI.message('Reading existing Manifest.')
              sftp.file.open(remote_manifest_path, 'w') do |remote_manifest|
                manifest = remote_manifest.gets
                json = JSON.parse(manifest)
                UI.message('[Uploader] Opened file from sftp...')
                puts '********************************************************'
                puts json
                puts '********************************************************'
              end
            end
          end
        rescue
          Fastlane::UI.message('[Uploader] No previous Manifest found.')
        end

        #
        # Check/delete remote (rename from metadata later) IPA
        # @params sftp, appcode, local_ipa_path, ;
        # @callees get_remote_ipa_path()
        #

        remote_ipa_path = get_remote_ipa_path(local_ipa_path)
        Fastlane::UI.message('[Uploader] Checking remote IPA.')
        begin
          sftp.stat!(remote_ipa_path) do |response|
            if response.ok?
              Fastlane::UI.message('[Uploader] Removing existing IPA...')
              sftp.remove!(remote_ipa_path)
            end
          end
        rescue
          Fastlane::UI.message('[Uploader] No previous IPA found.')
        end

        Fastlane::UI.message('[Uploader] Will upload IPA...')

        #
        # Upload current manifest.json
        # @params sftp, local_ipa_path, remote_ipa_path;
        # @callees generate_remote_path()
        #

        path = File.dirname(__FILE__) + '/' + local_ipa_path
        msg = '[Uploader] ' + path + ' to ' + remote_ipa_path
        Fastlane::UI.message(msg)
        sftp.upload!(path, remote_ipa_path)

        #
        # Upload current manifest.json
        # @params sftp, manifest_path, remote_manifest_path;
        # @callees generate_remote_path()
        #

        msg = '[Uploader] ' + manifest_path + ' to ' + remote_manifest_path

        Fastlane::UI.message(msg)
        sftp.upload!(manifest_path, remote_manifest_path)

        #
        # Lists the entries in a directory for verification
        #

        sftp.dir.foreach(remote_path) do |entry|
          Fastlane::UI.message(entry.longname)
        end
      end
    end

    # Private methods - Remote Operations

    def get_remote_ipa_path(ipa_path)
      path = generate_remote_path + appcode + '/' + File.basename(ipa_path)
      Fastlane::UI.message('[Uploader] remote_ipa_path: ' + path)
      path
    end

    def generate_remote_path
      path = '/home/' + user + '/repo/apps/'
      Fastlane::UI.message('[Uploader] generate_remote_path: ' + path)
      path
    end

    def remote_mkdir(sftp, remote_path)
      sftp.mkdir remote_path
    rescue Net::SFTP::StatusException => e
      raise if e.code != 11
      msg = '[Uploader] Remote dir ' + remote_path + ' exists.'
      Fastlane::UI.message(msg)
    end

    # Private methods - Local Operations

    def load_rsa_key(rsa_keypath)
      File.open(File.dirname(__FILE__) + '/' + rsa_keypath, 'r') do |file|
        rsa_key = [file.read]
        msg = '[Uploader] Successfully loaded RSA key...'
        Fastlane::UI.message(msg) unless rsa_key.nil?
        return rsa_key
      end
    end
  end
end

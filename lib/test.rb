#!/usr/bin/env ruby

require 'rubygems'
require 'net/ssh'
require 'net/sftp'

require 'fastlane'
require 'fastlane_core'

require_relative 'apprepo/options'

puts 'DEPRECATED in favour of Apprepo::Uploader!'

module AppRepo
  class Test
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

    def initialize
      Fastlane::UI.message('[AppRepo:Test] Initializing...')
      self.host = 'repo.teacloud.net'
      self.user = 'circle'
      self.password = 'circle'
      self.rsa_keypath = '../assets/circle.key'
      self.ipa_path = '../sampleapp.ipa'
      self.manifest_path = '../assets/example_manifest.json'
      self.appcode = 'APPREPO'
      # self.options = options
      # AppRepo::Test.new.run!
      # FastlaneCore::PrintTable.print_values(config: nil , hide_keys: [:app], mask_keys: ['app_review_information.demo_password'], title: "deliver #{AppRepo::VERSION} Summary") # options
    end

    # upload an ipa and manifest file or directory to the remote host
    def ssh_sftp_upload(ssh, local_ipa_path, manifest_path)
      ssh.sftp.connect do |sftp|
        ipa_name = File.basename(local_ipa_path)

        if File.exist?(local_ipa_path)
          Fastlane::UI.message('Local IPA found at ' + local_ipa_path)
        else
          Fastlane::UI.message('IPA at given path does not exist!')
          return
        end

        # Check/create remote directories

        remote_path = get_remote_path + appcode
        Fastlane::UI.message('Checking APPCODE at: ' + remote_path)

        remote_mkdir(sftp, remote_path)

        # Check/delete remote (rename from metadata later) IPA

        remote_ipa_path = get_remote_ipa_path(local_ipa_path)
        Fastlane::UI.message('Checking remote IPA.')
        begin
          sftp.stat!(remote_ipa_path) do |response|
            if response.ok?
              Fastlane::UI.message('Removing existing IPA...')
              sftp.remove!(remote_ipa_path)
            end
          end
        rescue
          Fastlane::UI.message('No previous IPA found.')
        end

        Fastlane::UI.message('Will upload IPA...')

        path = File.dirname(__FILE__) + '/' + local_ipa_path
        Fastlane::UI.message('Uploading IPA: ' + path + ' to path ' + remote_ipa_path)
        sftp.upload!(path, remote_ipa_path)

        remote_manifest_path = remote_path + '/manifest.json'

        Fastlane::UI.message('Checking remote Manifest.')
        begin
          sftp.stat!(remote_manifest_path) do |response|
            if response.ok?
              Fastlane::UI.message('Reading existing Manifest.')
              sftp.file.open(remote_manifest_path, 'w') do |_f|
                UI.message('opened file from sftp')
              end
            end
          end
        rescue
          Fastlane::UI.message('No previous Manifest found.')
        end

        Fastlane::UI.message('Uploading Manifest: ' + manifest_path + ' to path ' + remote_manifest_path)
        sftp.upload!(manifest_path, remote_manifest_path)

        # list the entries in a directory for verification
        sftp.dir.foreach(remote_path) do |entry|
          Fastlane::UI.message(entry.longname)
        end
      end
    end

    def remote_mkdir(sftp, remote_path)
      sftp.mkdir remote_path
    rescue Net::SFTP::StatusException => e
      if e.code == 11
        Fastlane::UI.message('Remote directory' + remote_path + ' already exists. OK...')
      else
        raise
      end
    end

    def load_rsa_key(rsa_keypath)
      File.open(File.dirname(__FILE__) + '/' + rsa_keypath, 'r') do |file|
        rsa_key = [file.read]
        Fastlane::UI.message('Successfully loaded RSA key...') unless rsa_key.nil?
        return rsa_key
      end
    end

    def get_remote_ipa_path(ipa_path)
      path = get_remote_path + appcode + '/' + File.basename(ipa_path)
      Fastlane::UI.message('remote_ipa_path: ' + path)
      path
    end

    def get_remote_path
      path = '/home/' + user + '/repo/apps/'
      Fastlane::UI.message('get_remote_path: ' + path)
      path
    end

    def run
      rsa_key = nil # load_rsa_key(self.rsa_keypath)
      if !rsa_key.nil?
        Fastlane::UI.message('Logging in with RSA key ' + rsa_keypath)
        Net::SSH.start(host, user, key_data: rsa_key, keys_only: true) do |ssh|
          Fastlane::UI.message('Logged in, uploading UPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      else
        Fastlane::UI.message('Logging in with username ' + user + ' and password *****...')
        Net::SSH.start(host, user, password: password) do |ssh|
          Fastlane::UI.message('Logged in, uploading UPA & Manifest...')
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      end
    end

    # test
    Test.new.run
  end # class
end # module

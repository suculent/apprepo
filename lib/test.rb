#!/usr/bin/env ruby

require 'rubygems'
require 'net/ssh'
require 'net/sftp'

require 'fastlane'
require 'fastlane_core'

require_relative 'apprepo/options'

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
      self.manifest_path = '../assets/manifest.json'
      self.appcode = 'APPREPO'
      #self.options = options
      #AppRepo::Test.new.run!
      #FastlaneCore::PrintTable.print_values(config: nil , hide_keys: [:app], mask_keys: ['app_review_information.demo_password'], title: "deliver #{AppRepo::VERSION} Summary") # options
    end

    # upload an ipa and manifest file or directory to the remote host
    def ssh_sftp_upload(ssh, ipa_path, manifest_path)  
      ssh.sftp.connect do |sftp|
        begin
          sftp.mkdir remote_path
        rescue Net::SFTP::StatusException => e
          if e.code == 11
            Fastlane::UI.message('Remote directory' + remote_path + ' already exists. OK...')
          else
            raise
          end
        end
        ipa_remote = remote_ipa_path(ipa_path)
        Fastlane::UI.message("Uploading IPA: "+ipa_remote)
        sftp.upload!(ipa_path, ipa_remote)
        sftp.upload!(manifest_path, remote_path + 'manifest.json')
        result = ssh.exec!('ls')
        Fastlane::UI.message(result)
      end
    end

    def load_rsa_key(rsa_keypath)
      File.open(File.dirname(__FILE__) + '/' + rsa_keypath, 'r') do |file|
        rsa_key = [file.read]
        return rsa_key
      end
    end

    def remote_ipa_path(ipa_path)
      path = remote_path + appcode + '/' + File.basename(ipa_path)
      Fastlane::UI.message("remote_ipa_path: " + path)
      return path
    end

    def remote_path
      path = '/home/' + user + '/repo/apps/'
      Fastlane::UI.message("remote_ipa: " + path)
      return path
    end

    # open and write to a pseudo-IO for a remote file
    #sftp.file.open(remote, 'w') do |f|
    #  UI.message("opened file from sftp")
    #end

    # list the entries in a directory
    #sftp.dir.foreach('.') do |entry|
    #  puts entry.longname
    #end

    def run
      # Login & Upload IPA with metadata using RSA key or username/password
      rsa_key = load_rsa_key(self.rsa_keypath)
      if rsa_key != nil
        Fastlane::UI.message("Logging in with RSA key " + rsa_keypath)
        Net::SSH.start( host, user, :key_data => rsa_key, :keys_only => true) do |ssh|
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      else
        # Login with 
        Fastlane::UI.message("Logging in with username " + username + " and password *****...")
        Net::SSH.start(host, user, password: password) do |ssh|
          ssh_sftp_upload(ssh, ipa_path, manifest_path)
        end
      end
    end

    # test
    Test.new.run

  end # class
end # module
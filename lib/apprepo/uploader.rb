require 'rubygems'
require 'net/ssh'
require 'net/sftp'
require 'fastlane_core/languages'
require_relative 'upload_descriptor'

module AppRepo
  class Uploader

    attr_accessor :host
    attr_accessor :login
    attr_accessor :keypath
    attr_accessor :appcode
    attr_accessor :upload_descriptor

    attr_accessor :ipa
  

    def initialize(host, login, keypath, appcode)
      self.host = host
      self.login = login
      self.keypath = keypath
      self.appcode = appcode

      UI.message('[AppRepo:Uploader] Initializing...')


      path = File.dirname(__FILE__)+'/../../*.ipa'
      puts path

      self.ipa = Dir.glob(path).last
      puts ipa

      
      UI.message('[DEBUG]:' + self.host + ' | ' + self.login + ' | ' + self.keypath + ' | ' + self.appcode )
    end

    def run

      if !appcode 
        UI.user_error('APPCODE value missing.')
        exit 0
      end

      if !ipa
        UI.user_error('IPA value missing.')
        exit 0
      end

      File.open(keypath, 'r') do |file|
        UI.message('[AppRepo:Uploader] reading private key...')

        rsa_key = [file.read]

        UI.message('[AppRepo:Uploader] starting SSH connection...')

        Net::SSH.start(host, login, password: 'circle') do |ssh|
          # Net::SSH.start( self.host, self.login, :key_data => rsa_key, :keys_only => true) do |ssh|

          UI.message('[AppRepo:Uploader] logging to AppRepo...')

          ssh.sftp.connect do |sftp|

            UI.message('[AppRepo:Uploader] AppRepo successfully connected...')

            UI.message('[AppRepo:Uploader] TODO: Traverse to correct "APPCODE" folder...')

            result = ssh.exec!('cd repo/apps/' + self.appcode + '; ls')
            UI.message(result)

            UI.message('Will try to upload ' + self.ipa )

            # upload a file or directory to the remote host
            sftp.upload!( self.ipa , '/home/circle/repo/test.data')

            result = ssh.exec!('ls')

            UI.message(result)

            remote = '/home/circle/repo/test.data'
            local = '/Users/sychram/test.data.from-remote'

            # download a file or directory from the remote host
            sftp.download!(remote, local)

            # grab data off the remote host directly to a buffer
            data = sftp.download!(remote)

            # open and write to a pseudo-IO for a remote file
            sftp.file.open(remote, 'w') do |f|
              f.puts "Hello, world!\n"
            end

            # open and read from a pseudo-IO for a remote file
            sftp.file.open(remote, 'r') do |f|
              puts f.gets
            end

            directory = '/home/circle/ruby-test'

            # safely make a directory
            begin
            sftp.mkdir directory
          rescue Net::SFTP::StatusException => e
            # verify if this returns 11. Your server may return
            # something different like 4.
            if e.code == 11
              # warning?
              UI.user_error('directory already exists. Carry on...')
              sftp.rmdir!('/home/circle/ruby-test')
            else
              raise
            end

          end

            # list the entries in a directory
            sftp.dir.foreach('.') do |entry|
              puts entry.longname
            end
          end
        end
      end
end

    # upload = new AppRepo:Upload('repo.teacloud.net', 'circle', '/Users/sychram/.ssh/REPOKey.pem')
  end
end

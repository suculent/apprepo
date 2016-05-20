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

    def initialize (host, login, keypath)
      self.host = host
      self.login = login
      self.keypath = keypath
      puts 'Initializing "AppRepo:Uploader"'
    end

    def run

      File.open(self.keypath, "r") do |file|  

        puts '[AppRepo:Uploader] reading private key...'

        rsa_key = [ file.read ]

        puts '[AppRepo:Uploader] starting SSH connection...'

        Net::SSH.start( self.host, self.login, :key_data => rsa_key, :keys_only => true) do |ssh|

          puts '[AppRepo:Uploader] logging to AppRepo...'

          ssh.sftp.connect do |sftp|

            puts '[AppRepo:Uploader] AppRepo successfully connected...'

            puts '[AppRepo:Uploader] TODO: Traverse to correct "APPCODE" folder...'

            result = ssh.exec!('cd repo/apps; ls')
            puts result

          # upload a file or directory to the remote host
          sftp.upload!("/Users/sychram/test.data", "/home/circle/repo/test.data")

          result = ssh.exec!('ls')

          puts result

          remote = '/home/circle/repo/test.data'
          local = '/Users/sychram/test.data.from-remote'

          # download a file or directory from the remote host
          sftp.download!(remote, local)

          # grab data off the remote host directly to a buffer
          data = sftp.download!(remote)

          # open and write to a pseudo-IO for a remote file
          sftp.file.open(remote, "w") do |f|
            f.puts "Hello, world!\n"
          end

          # open and read from a pseudo-IO for a remote file
          sftp.file.open(remote, "r") do |f|
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
            puts "directory already exists. Carry on..."
            sftp.rmdir!("/home/circle/ruby-test")
          else 
            raise
          end 

        end

        # list the entries in a directory
        sftp.dir.foreach(".") do |entry|
          puts entry.longname
        end
      end
    end
  end
end

#upload = new AppRepo:Upload('repo.teacloud.net', 'ubuntu', '/Users/sychram/.ssh/REPOKey.pem')

end
end
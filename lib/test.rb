#!/usr/bin/env ruby
require 'rubygems'
require 'net/ssh'
require 'net/sftp'

#
# These want to be an input parameters:
#

host = 'repo.teacloud.net'
user = 'ubuntu'
keypath = '/Users/sychram/.ssh/REPOKey.pem'

File.open(keypath, "r") do |file|  

  rsa_key = [ file.read ]

    Net::SSH.start( host, user, :key_data => rsa_key, :keys_only => true) do |ssh|
    
    ssh.sftp.connect do |sftp|
      
      # upload a file or directory to the remote host
      sftp.upload!("/Users/sychram/test.data", "/home/ubuntu/repo/test.data")

      result = ssh.exec!('ls')

      puts result

      remote = '/home/ubuntu/repo/test.data'
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

      directory = '/home/ubuntu/ruby-test'

      # safely make a directory      
      begin
          sftp.mkdir directory
      rescue Net::SFTP::StatusException => e
          # verify if this returns 11. Your server may return
          # something different like 4.
          if e.code == 11
              puts "directory already exists. Carry on..."
              sftp.rmdir!("/home/ubuntu/ruby-test")
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
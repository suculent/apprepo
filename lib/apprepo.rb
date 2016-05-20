#!/usr/bin/env ruby

require 'json'
require_relative 'apprepo/version'
require_relative 'apprepo/test'
require_relative 'apprepo/upload_desciptor'
#require 'fastlane_core'

module AppRepo

  class << self
  	  def initialize
      puts 'Initializing "AppRepo:Uploader"'
      end
  end
  
  # Should read following parameters from fastlane/Repofile:

  #test only
  upload = Uploader.new('repo.teacloud.net', 'ubuntu', '/Users/sychram/.ssh/REPOKey.pem')
  uploadDescriptor = UploadDescriptor.new("APPREPO")  
  upload.run

end
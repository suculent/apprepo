#!/usr/bin/env ruby

require 'json'

require_relative 'apprepo/version'
require_relative 'apprepo/options'

require_relative 'apprepo/uploader'
require_relative 'apprepo/upload_metadata'
require_relative 'apprepo/upload_assets'
require_relative 'apprepo/commands_generator'

require_relative 'apprepo/detect_values'
require_relative 'apprepo/runner'
require_relative 'apprepo/setup'
require_relative 'apprepo/loader'

require_relative 'apprepo/upload_descriptor' # will deprecate or replace :app info

require 'fastlane_core'

module AppRepo

  class << self
  	  def initialize
      puts 'Initializing "AppRepo:Uploader"'
      end
  end
  
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  # Will read following parameters from fastlane/Repofile in future

  upload = Uploader.new('repo.teacloud.net', 'circle', File.dirname(__FILE__)+'/../assets/circle.key')
  uploadDescriptor = UploadDescriptor.new("APPREPO")  
  upload.run
end
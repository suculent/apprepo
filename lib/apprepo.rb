#!/usr/bin/env ruby

# encoding: utf-8

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
        UI.message('[AppRepo] Initializing...')
      end
      
      def new
        UI.message('[AppRepo] New...')
      end
  end

  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8

  # Generate options (simulates commands_generator.rb)
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  appcode = 'ruby-test'

  # Setup descriptor (appcode, ipa, metadata - from repofile)!
  UI.message('[AppRepoTest] UploadDescriptor.new')
  uploadDescriptor = UploadDescriptor.new(appcode) # not used yet
  uploadDescriptor.appcode = appcode

  # Test Uploader (OK)
  # UI.message('[AppRepoTest] Uploader.new')
  # upload = Uploader.new('repo.teacloud.net', 'circle', File.dirname(__FILE__) + '/../assets/circle.key', appcode)
  # upload.run

  UI.message('[AppRepoTest] AppRepo::CommandsGenerator.new.run')
  CommandsGenerator.new.run
end

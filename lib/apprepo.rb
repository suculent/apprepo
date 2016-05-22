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
        UI.message('[AppRepo] Initializing...')
      end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  # Test Setup (Repofile)
  setup = AppRepo::Setup.new()
  setup.run

  # Setup descriptor (appcode, ipa, metadata - from repofile)!
  uploadDescriptor = UploadDescriptor.new(appcode) # not used yet
  upload.run

  # Test Uploader (Core)
  appcode = 'ruby-test'
  upload = Uploader.new('repo.teacloud.net', 'circle', File.dirname(__FILE__) + '/../assets/circle.key', appcode)

  

  # Test Runner (Uploader Delegate)
  runner = AppRepo::Runner.new()
  runner.run

end

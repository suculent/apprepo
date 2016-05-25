#!/usr/bin/env ruby

# encoding: utf-8

require 'json'

require_relative 'apprepo/analyser'
require_relative 'apprepo/commands_generator'
require_relative 'apprepo/detect_values'
require_relative 'apprepo/download_metadata'
require_relative 'apprepo/loader'
require_relative 'apprepo/manifest'
require_relative 'apprepo/options'
require_relative 'apprepo/runner'
require_relative 'apprepo/setup'
require_relative 'apprepo/uploader'
require_relative 'apprepo/version'

require 'fastlane_core'

# Root class of the AppRepo SFTP Uploader
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

  Helper = FastlaneCore::Helper
  UI = FastlaneCore::UI

  # Test
  UI.message('[AppRepo] AppRepo::CommandsGenerator.new.run')
  CommandsGenerator.new.run
end

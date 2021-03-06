#!/usr/bin/env ruby

# encoding: utf-8

require 'json'

require_relative 'apprepo/analyser'
require_relative 'apprepo/commands_generator'
require_relative 'apprepo/detect_values'
require_relative 'apprepo/loader'
require_relative 'apprepo/manifest'
require_relative 'apprepo/options'
require_relative 'apprepo/runner'
require_relative 'apprepo/setup'
require_relative 'apprepo/uploader'
require_relative 'apprepo/version'

require 'fastlane'
require 'fastlane_core'

# Root class of the AppRepo SFTP Uploader
module AppRepo
  class << self
      def initialize
        UI.message('AppRepo:self Initializing...')
      end

      def new
        UI.message('AppRepo:new')
      end

      def download_manifest
        cgen = CommandsGenerator.new
        cgen.download_manifest
      end

      def run
        cgen = CommandsGenerator.new
        cgen.run
      end
  end

  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8

  Helper = FastlaneCore::Helper
  UI = FastlaneCore::UI
  
  # Test only, should be removed...
  UI.message('Initializing new CommandsGenerator')
  cgen = CommandsGenerator.new
  UI.message('Downloading Manifest...')
  cgen.download_manifest
  UI.message('Running Deployment...')
  cgen.run
end

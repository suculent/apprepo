require_relative 'uploader'
require 'fastlane_core'

module AppRepo
  # Should provide metadata for current appcode
  class Analyser
    attr_accessor :options

    def initialize(options)
      self.options = options
    end

    # Fetches remote app version from metadata
    def fetch_app_version(options)
      metadata = AppRepo::Uploader.new(options).download_manifest_only
      FastlaneCore::UI.user_error!('TODO: Parse version out from metadata')
      '0.0'
    end

    # only for testing, should be empty
    def run
      FastlaneCore::UI.message('AppRepo:Analyser.run for test...')
      fetch_app_version(options)
    end
  end
end

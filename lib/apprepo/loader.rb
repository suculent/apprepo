#require 'fastlane_core/languages'

module AppRepo
  # Responsible for loading language folders
  module Loader
    def self.language_folders(root)
      Dir.glob(File.join(root, '*')).select do |path|
        all = ALL_LANGUAGES.include?(File.basename(path).downcase)
        File.directory?(path) && all
      end.sort
    end
  end
end

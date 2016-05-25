module AppRepo
  class DetectValues
    def run!(options)
      # find_app_identifier(options
      find_folders(options)
      find_version(options)
    end

    def find_app_identifier(options)
      return if options[:app_identifier]

      if options[:ipa]
        identifier = FastlaneCore::IpaFileAnalyser.fetch_app_identifier(options[:ipa])
      elsif options[:pkg]
        identifier = FastlaneCore::PkgFileAnalyser.fetch_app_identifier(options[:pkg])
      end

      options[:app_identifier] = identifier if identifier.to_s.length > 0
      options[:app_identifier] ||= UI.input('The Bundle Identifier of your App: ')
    end

    def find_folders(options)
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'
      unless options[:manifest_path].nil?
        puts "Containing: '" + options[:manifest_path] + "' folder for TODO RENAME example_manifest.json"
        options[:manifest_path] ||= File.join(containing, '/../manifest.json')
        puts "Options: '" + options[:manifest_path] + "'"
        FileUtils.mkdir_p(options[:manifest_path])
    end
    end

    def find_version(options)
      unless options[:ipa].nil?
        options[:app_version] ||= FastlaneCore::IpaFileAnalyser.fetch_app_version(options[:ipa])
      end
    end
  end
end

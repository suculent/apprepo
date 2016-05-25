module AppRepo
  # This class is responsible for detecting values from IPA.
  class DetectValues
    def run!(options)
      find_app_identifier(options)
      find_folders(options)
      find_version(options)
    end

    def find_app_identifier(options)
      puts '[AppRepo:DetectValues] find_app_identifier...'
      return if options[:app_identifier]

      if options[:ipa]
        # identifier = AppRepo::Analyser.fetch_app_identifier(options[:ipa])
      end

      options[:app_identifier] = identifier if identifier.to_s!empty?
      input_message = 'The Bundle Identifier of your App: '
      options[:app_identifier] ||= UI.input(input_message)
    end

    # rubocop:disable Metrics/AbcSize
    def find_folders(options)
      puts '[AppRepo:DetectValues] find_folders...'
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'
      return if options[:manifest_path].nil?
      puts "Manifest path: '" + options[:manifest_path] + "'"
      options[:manifest_path] ||= File.join(containing, '/../manifest.json')
      puts "Options: '" + options[:manifest_path] + "'"
      FileUtils.mkdir_p(options[:manifest_path])
    end

    def find_version(options)
      puts '[AppRepo:DetectValues] find_version...'
      unless options[:ipa].nil?
        opt = AppRepo::Analyser.fetch_app_version(options[:ipa])
        options[:app_version] ||= opt
      end
    end
  end
end

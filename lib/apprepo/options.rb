require 'fastlane_core'

module AppRepo
  class Options
    def self.available_options
      [
        FastlaneCore::ConfigItem.new(key: :app,
                                     short_option: '-p',
                                     env_name: 'DELIVER_APP_ID',
                                     description: 'The app ID of the app you want to use/modify',
                                     is_string: false), # don't add any verification here, as it's used to store a spaceship ref
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     short_option: '-i',
                                     optional: true,
                                     env_name: 'DELIVER_IPA_PATH',
                                     description: 'Path to your ipa file',
                                     default_value: Dir['*.ipa'].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find ipa file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?('.ipa')
                                     end,
                                     conflicting_options: [:pkg],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :pkg,
                                     short_option: '-c',
                                     optional: true,
                                     env_name: 'DELIVER_PKG_PATH',
                                     description: 'Path to your pkg file',
                                     default_value: Dir['*.pkg'].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find pkg file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a pkg file") unless value.end_with?('.pkg')
                                     end,
                                     conflicting_options: [:ipa],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'pkg' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :metadata_path,
                                     short_option: '-m',
                                     description: 'Path to the folder containing the metadata files',
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_binary_upload,
                                     description: 'Skip uploading an ipa or pkg to iTunes Connect',
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :app_version,
                                     short_option: '-z',
                                     description: 'The version that should be edited or created',
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_metadata,
                                     description: "Don't upload the metadata (e.g. title, description), this will still upload screenshots",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :build_number,
                                     short_option: '-n',
                                     description: 'If set the given build number (already uploaded to iTC) will be used instead of the current built one',
                                     optional: true,
                                     conflicting_options: [:ipa, :pkg],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'build_number' and '#{value.key}' options in one run.")
                                     end),

        # App Metadata
        # Non Localised
        FastlaneCore::ConfigItem.new(key: :app_icon,
                                     description: 'Metadata: The path to the app icon',
                                     optional: true,
                                     short_option: '-l',
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find png file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a png file") unless value.end_with?('.png')
                                     end)
      ]
    end
  end
end

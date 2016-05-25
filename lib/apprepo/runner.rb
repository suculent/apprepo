require_relative 'uploader'

module AppRepo
  # Responsible for running
  class Runner
    attr_accessor :options

    def initialize(options)
      UI.message('[AppRepo:Runner] Initializing...')
      self.options = options
      AppRepo::DetectValues.new.run!(self.options)
      # FastlaneCore::PrintTable.print_values(config: options,
      # hide_keys: [:app], mask_keys: [],
      # title: "deliver #{AppRepo::VERSION} Summary")
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def run
      UI.success('[AppRepo:Runner] Running!')
      verify_version if !options[:app_version].to_s.empty?
      upload_metadata

      has_binary = (options[:ipa] || options[:pkg])
      if !options[:skip_binary_upload] && !options[:build_number] && has_binary
        upload_binary
      end

      UI.success('Finished the upload to AppRepo.')
      notify unless options[:notify].nil?
    end

    # Make sure the version on AppRepo matches the one in the ipa
    # If not, the new version will automatically be created
    def verify_version
      app_version = options[:app_version]
      msg = "TODO: Test if AppRepo matches '#{app_version}' from the IPA..."
      UI.message(msg)

      # changed = options[:app].ensure_version!(app_version)
      # if changed
      #  UI.success("Successfully set the version to '#{app_version}'")
      # else
      #  UI.success("'#{app_version}' is the latest version on AppRepo")
      # end
    end

    # Upload all metadata, screenshots, pricing information, etc. to AppRepo
    def upload_metadata
      #
    end

    # Upload the binary to AppRepo
    def upload_binary
      UI.message('Uploading binary to AppRepo')
      if options[:ipa]
        AppRepo::Uploader.new(options)
        # result = transporter.upload(options[:app].apple_id, package_path)
        msg = 'Binary upload failed. Check out the error above'
        UI.user_error!(msg) unless result
      end
    end

    def notify
      # should be in metadata
    end
  end
end

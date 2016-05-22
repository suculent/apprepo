module AppRepo
  class Runner
    attr_accessor :options

    def initialize(options)
      UI.message('[AppRepo:Runner] Initializing...')
      self.options = options
      #login
      AppRepo::DetectValues.new.run!(self.options)
      #FastlaneCore::PrintTable.print_values(config: options, hide_keys: [:app], mask_keys: ['app_review_information.demo_password'], title: "deliver #{AppRepo::VERSION} Summary")
    end

    def login
      #UI.message("Login to AppRepo (#{options[:username]})")
      #AppRepo::Server.login(options[:username])
      #AppRepo::Server.select_app
      #UI.message('Login successful')
    end

    def run
      verify_version if options[:app_version].to_s.length > 0
      upload_metadata

      has_binary = (options[:ipa] || options[:pkg])
      if !options[:skip_binary_upload] && !options[:build_number] && has_binary
        upload_binary
      end

      UI.success('Finished the upload to AppRepo')

      notify if options[:notify]
    end

    # Make sure the version on AppRepo matches the one in the ipa
    # If not, the new version will automatically be created
    def verify_version
      app_version = options[:app_version]
      UI.message("Making sure the latest version on iTunes Connect matches '#{app_version}' from the ipa file...")

      #changed = options[:app].ensure_version!(app_version)
      #if changed
      #  UI.success("Successfully set the version to '#{app_version}'")
      #else
      #  UI.success("'#{app_version}' is the latest version on iTunes Connect")
      #end
    end

    # Upload all metadata, screenshots, pricing information, etc. to iTunes Connect
    def upload_metadata
      #
    end

    # Upload the binary to iTunes Connect
    def upload_binary
      UI.message('Uploading binary to iTunes Connect')
      if options[:ipa]
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: options[:app].apple_id,
          ipa_path: options[:ipa],
          package_path: '/tmp'
        )
      end

      #transporter = FastlaneCore::ItunesTransporter.new(options[:username])
      #result = transporter.upload(options[:app].apple_id, package_path)
      #UI.user_error!('Could not upload binary to iTunes Connect. Check out the error above') unless result
    end

    def notify
      # should be in metadata
    end

    private

  end
end

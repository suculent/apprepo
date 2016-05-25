require 'commander'

HighLine.track_eof = false

module AppRepo
  # This class is responsible for providing commands with respective actions
  class CommandsGenerator
    include Commander::Methods

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update('apprepo')
      new.run
    ensure
      checker = FastlaneCore::UpdateChecker
      checker.show_update_status('apprepo', AppRepo::VERSION)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Style/GlobalVars
    def run
      program :version, AppRepo::VERSION
      program :description, AppRepo::DESCRIPTION
      program :help, 'Author', 'Matej Sychra <suculent@me.com>'
      program :help, 'Website', 'https://github.com/suculent/apprepo'
      program :help, 'GitHub', 'https://github.com/suculent/apprepo/tree/master/apprepo'
      program :help_formatter, :compact

      generator = FastlaneCore::CommanderGenerator.new
      generator.generate(AppRepo::Options.available_options)

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'apprepo'
        c.description = 'Upload IPA and metadata to SFTP (e.g. AppRepo)'
        c.action do |_args, options|
          config = FastlaneCore::Configuration
          available_opts = AppRepo::Options.available_options
          options = config.create(available_opts, options.__hash__)
          loaded = options.load_configuration_file('Repofile')
          loaded = true if options[:repo_description] || options[:ipa]

          unless loaded
            puts '[AppRepo::CommandsGenerator] configuration file not loaded'
            if UI.confirm('No Repofile found. Do you want to setup apprepo?')
              require 'apprepo/setup'
              AppRepo::Setup.new.run(options)
              puts '[AppRepo::CommandsGenerator] exiting.'
              return 0
            end
          end

          AppRepo::Runner.new(options).run
        end
      end

      command :download_manifest do |c|
        c.syntax = 'apprepo download manifest'
        c.description = 'Downloads existing metadata and stores it locally.
        This overwrites the local files.'

        c.action do |_args, options|
          config = FastlaneCore::Configuration
          available_opts = AppRepo::Options.available_options
          options = config.create(available_opts, options.__hash__)
          options.load_configuration_file('Repofile')
          AppRepo::Runner.new(options) # to login...
          cont = FastlaneCore::Helper.fastlane_enabled? ? './fastlane' : '.'
          path = options[:manifest_path] || File.join(cont, 'metadata')
          res = ENV['APPREPO_FORCE_OVERWRITE']
          msg = 'Do you want to overwrite existing metadata on path '
          res ||= UI.confirm(msg + '#{File.expand_path(path)}' + '?')
          return 0 if res.nil?
          require 'apprepo/setup'
          # TODO: Fetch version from IPA or else
          v = options[:app_version].latest_version
          AppRepo::Setup.new.generate_metadata_files(v, path)
        end
      end

      command :submit do |c|
        c.syntax = 'apprepo submit'
        c.description = 'Submit a specific build-nr, use latest.'
        c.action do |_args, options|
          config = FastlaneCore::Configuration
          available_opts = AppRepo::Options.available_options
          options = config.create(available_opts, options.__hash__)
          options.load_configuration_file('Repofile')
          options[:submit_for_review] = true
          options[:build_number] = 'latest' unless options[:build_number]
          AppRepo::Runner.new(options).run
        end
      end

      command :init do |c|
        c.syntax = 'apprepo init'
        c.description = 'Create the initial `apprepo` configuration'
        c.action do |_args, options|
          if File.exist?('Repofile') || File.exist?('fastlane/Repofile')
            UI.important('You already got a running apprepo setup.')
            return 0
          end

          require 'apprepo/setup'
          config = FastlaneCore::Configuration
          available_opts = AppRepo::Options.available_options
          options = config.create(available_opts, options.__hash__)
          AppRepo::Runner.new(options) # to login...
          AppRepo::Setup.new.run(options)
        end
      end

      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      default_command :run

      run!
    end
  end
end

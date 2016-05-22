require 'commander'

HighLine.track_eof = false

module AppRepo
  class CommandsGenerator
    include Commander::Methods

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update('apprepo')
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status('apprepo', AppRepo::VERSION)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def run
      program :version, AppRepo::VERSION
      program :description, AppRepo::DESCRIPTION
      program :help, 'Author', 'Matej Sychra <suculent@me.com>'
      program :help, 'Website', 'https://github.com/suculent/apprepo'
      program :help, 'GitHub', 'https://github.com/suculent/apprepo/tree/master/apprepo'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(AppRepo::Options.available_options)

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'apprepo'
        c.description = 'Upload IPA and metadata to SFTP (e.g. AppRepo)'
        c.action do |_args, options|
          options = FastlaneCore::Configuration.create(AppRepo::Options.available_options, options.__hash__)
          loaded = options.load_configuration_file('Repofile')
          loaded = true if options[:description] || options[:ipa] || options[:pkg] # do we have *anything* here?
          unless loaded
            if UI.confirm('No AppRepo configuration found in the current directory. Do you want to setup apprepo?')
              require 'apprepo/setup'
              # AppRepo::Runner.new(options) # to login...
              AppRepo::Setup.new.run(options)
              return 0
            end
          end

          AppRepo::Runner.new(options).run
        end
      end
      command :submit_build do |c|
        c.syntax = 'apprepo submit_build'
        c.description = 'Submit a specific build-nr for review, use latest for the latest build'
        c.action do |_args, options|
          options = FastlaneCore::Configuration.create(AppRepo::Options.available_options, options.__hash__)
          options.load_configuration_file('Repofile')
          options[:submit_for_review] = true
          options[:build_number] = 'latest' unless options[:build_number]
          AppRepo::Runner.new(options).run
        end
      end
      command :init do |c|
        c.syntax = 'apprepo init'
        c.description = 'Create the initial `apprepo` configuration based on an existing app'
        c.action do |_args, options|
          if File.exist?('Repofile') || File.exist?('fastlane/Repofile')
            UI.important('You already got a running apprepo setup in this directory')
            return 0
          end

          require 'apprepo/setup'
          options = FastlaneCore::Configuration.create(AppRepo::Options.available_options, options.__hash__)
          AppRepo::Runner.new(options) # to login...
          AppRepo::Setup.new.run(options)
        end
      end

      command :download_metadata do |c|
        c.syntax = 'apprepo download_metadata'
        c.description = 'Downloads existing metadata and stores it locally. This overwrites the local files.'

        c.action do |_args, options|
          options = FastlaneCore::Configuration.create(AppRepo::Options.available_options, options.__hash__)
          options.load_configuration_file('Repofile')
          AppRepo::Runner.new(options) # to login...
          containing = FastlaneCore::Helper.fastlane_enabled? ? './fastlane' : '.'
          path = options[:metadata_path] || File.join(containing, 'metadata')
          res = ENV['DELIVER_FORCE_OVERWRITE']
          res ||= UI.confirm("Do you want to overwrite existing metadata on path '#{File.expand_path(path)}'?")
          if res
            require 'apprepo/setup'
            v = options[:app].latest_version
            AppRepo::Setup.new.generate_metadata_files(v, path)
          else
            return 0
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      default_command :run

      run!
    end
  end
end

module AppRepo
  class Setup
    def run(options)
      UI.message('[AppRepo:Setup] Running...')
      containing = (File.directory?('fastlane') ? 'fastlane' : '.')
      file_path = File.join(containing, 'Repofile')
      data = generate_apprepo_file(containing, options)
      setup_apprepo(file_path, data, containing, options)
    end

    def setup_apprepo(file_path, data, _apprepo_path, _options)
      File.write(file_path, data)

      # TODO: implement later
      # download_metadata(apprepo_path, options)

      UI.success("Successfully created new Repofile at path '#{file_path}'")
    end

    # This method takes care of creating a new 'apprepo' folder, containg the app metadata
    # and screenshots folders
    def generate_apprepo_file(apprepo_path, options)
      #
      #v = options[:app].latest_version
      #generate_metadata_files(v, File.join(apprepo_path, 'metadata'))

      # Generate the final Repofile here
      gem_path = Helper.gem_path('apprepo')
      deliver = File.read("#{gem_path}/assets/RepofileDefault")
      #deliver.gsub!('[[APP_IDENTIFIER]]', options[:app].bundle_id)
      # deliver.gsub!("[[APP_IPA]]", options[:app]...)
      # deliver.gsub!("[[APP_VERSION]]", options[:app].version)
      # deliver.gsub!("[[APP_NAME]]", options[:app].name)
      UI.success("TODO: ADJUST Repofile'")
      deliver
    end

    def download_metadata(apprepo_path, _options)
      path = File.join(apprepo_path, 'metadata')
      FileUtils.mkdir_p(path)
      UI.success("TODO: DOWNLOAD METADATA'")
      # AppRepo::DownloadManifest.run(options, path)
    end
  end
end

# @setup = new AppRepo::Setup

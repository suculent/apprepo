module AppRepo
  # Responsible for downloading manifest.json from AppRepo
  # Should be part of uploader. No need for separate class.
  class DownloadMetadata
    def self.run(options, path)
      UI.message('TODO: Download existing manifest.json...')
      download(options, path)
      UI.success('TODO: PROCESS: Successfully downloaded manifest.json...')
    rescue => ex
      UI.error(ex)
      UI.error("Couldn't download already existing manifest from AppRepo.")
    end

    def self.download(_options, _folder_path)
      UI.message('TODO: DOWNLOAD existing manifest.json NOT IMPLEMENTED')

      # v = options[:app].latest_version
    end
  end
end

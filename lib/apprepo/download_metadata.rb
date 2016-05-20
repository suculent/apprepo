module AppRepo
  class DownloadMetadata
    def self.run(options, path)
      UI.message("Downloading existing metadata.json...")
      download(options, path)
      UI.success("Successfully downloaded all metadata")
    rescue => ex
      UI.error(ex)
      UI.error("Couldn't download already existing metadata from AppRepo.")
    end

    def self.download(options, folder_path)
    
      UI.message("TODO: DOWNLOAD existing metadata.json NOT IMPLEMENTED")

      # v = options[:app].latest_version

      # v.screenshots.each do |language, screenshots|
      #   screenshots.each do |screenshot|
      #     file_name = [screenshot.sort_order, screenshot.device_type, screenshot.sort_order].join("_")
      #     original_file_extension = File.basename(screenshot.original_file_name)
      #     file_name += "." + original_file_extension

      #     UI.message("Downloading existing screenshot '#{file_name}'")

      #     # If the screen shot is for an appleTV we need to store it in a way that we'll know it's an appleTV
      #     # screen shot later as the screen size is the same as an iPhone 6 Plus in landscape.
      #     if screenshot.device_type == "appleTV"
      #       containing_folder = File.join(folder_path, "appleTV", screenshot.language)
      #     else
      #       containing_folder = File.join(folder_path, screenshot.language)
      #     end

      #     begin
      #       FileUtils.mkdir_p(containing_folder)
      #     rescue
      #       # if it's already there
      #     end
      #     path = File.join(containing_folder, file_name)
      #     File.write(path, open(screenshot.url).read)
      #   end
      # end
      
    end
  end
end

require 'webmock/rspec'
require 'apprepo/uploader'

# require 'apprepo'

describe AppRepo do
  describe AppRepo::Uploader do
    it 'properly uploads existing IPA metadata' do
      # app = "app"
      # version = "version"
      # allow(Spaceship::Application).to receive(:find).and_return(app)
      # expect(app).to receive(:latest_version).and_return(version)
      # expect(version).to receive(:name).and_return("name")

      # options = {
      #   app_identifier: "tools.fastlane.app",
      #   username: "flapple@krausefx.com",
      # }
      # Deliver::Runner.new(options)
      # Deliver::Setup.new.run(options)
      upload = AppRepo::Uploader.new('repo.teacloud.net', 'ubuntu', '/Users/sychram/.ssh/REPOKey.pem') # to login
      uploadDescriptor = AppRepo::UploadDescriptor.new('APPREPO')
      upload.run
    end
  end
end

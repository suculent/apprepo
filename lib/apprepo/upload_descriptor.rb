module AppRepo
  class UploadDescriptor
    attr_accessor :appcode # required
    attr_accessor :ipa # can be inferred anyway (glob or metadata)
    attr_accessor :metadata # optional, allows re-uploading same binary without metadata change

    def initialize(appcode)
      self.appcode = appcode
      UI.message('Initializing "AppRepo:UploadDescriptor with appcode "' + self.appcode + '"')
    end
  end
end

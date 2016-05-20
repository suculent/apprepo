module AppRepo

class UploadDescriptor

  attr_accessor :appcode

  def initialize (appcode)
    self.appcode = appcode
    puts 'Initializing "AppRepo:UploadDescriptor with appcode "'+self.appcode+'"'
  end
end

end
    
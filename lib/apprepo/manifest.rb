module AppRepo

class Manifest

#
# Translated internal key names from Fastlane to AppRepo
#

  attr_accessor :appcode             # AppRepo Internal Code
  attr_accessor :filename            # IPA file name
  attr_accessor :bundle_identifier   # app_identifier
  attr_accessor :bundle_version      # app_version
  attr_accessor :title               # app_name
  attr_accessor :subtitle            # app_description
  attr_accessor :notify              # will send push notification / slack
  
  def initialize (appcode)
    self.appcode = appcode
    puts 'Initializing "AppRepo:Manifest requies at least APPCODE :"'+self.appcode
  end
  
  # Provide JSON serialized data 
  def getJSON
      structure = {
          appcode: self.appcode,
          filename: self.filename,
          bundle_identifier: self.bundle_identifier,
          bundle_version: self.bundle_version,
          title: self.title,
          subtitle: self.subtitle,
          notify: self.notify
      }
      
      fputs structure
  end
  
end
end
    
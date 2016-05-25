module AppRepo
    
  # Should provide metadata from current context
  class Analyser
      
    attr_accessor :options
      
    def initialize(options)
        self.options = options
    end
    
    def fetch_app_version(options_ipa)
    	# TODO: parse options_ipa
        return "0.0"
    end
    
    def run
    end
    
  end
end

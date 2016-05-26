require 'coveralls'
Coveralls.wear! # unless ENV['FASTLANE_SKIP_UPDATE_CHECK']

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'fastlane'
require 'fastlane_core'

# This module is only used to check the environment is currently a testing env
# Needs to be above the `require 'apprepo'`
module SpecHelper
end

require 'apprepo'

ENV['APPREPO_USER'] = 'circle'
ENV['APPREPO_PASSWORD'] = 'circle'

RSpec.configure do |config|
  config.before(:each) do
    # 'RSpec.configure is empty in spec_helper.rb'
  end
end

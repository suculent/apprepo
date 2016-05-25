# require 'coveralls'
# Coveralls.wear! unless ENV['FASTLANE_SKIP_UPDATE_CHECK']

# This module is only used to check the environment is currently a testing env
# Needs to be above the `require 'apprepo'`
module SpecHelper
end

require 'fastlane'
require 'fastlane_core'
require 'webmock/rspec'
require 'apprepo'

ENV['APPREPO_USER'] = 'circle'
ENV['APPREPO_PASSWORD'] = 'circle'

RSpec.configure do |config|
  config.before(:each) do
    # we do not authenticate against spaceship but apprepo here.
    # where will the ssh session be strongly held?
    puts 'RSpec.configure is empty in spec_helper.rb'
  end
end

# WebMock.disable_net_connect!(allow: 'coveralls.io')

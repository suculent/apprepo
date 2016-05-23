require 'coveralls'
Coveralls.wear! unless ENV['FASTLANE_SKIP_UPDATE_CHECK']

# This module is only used to check the environment is currently a testing env
# Needs to be above the `require 'apprepo'`
module SpecHelper
end

require 'apprepo'
require 'webmock/rspec'

ENV['APPREPO_USER'] = 'DELIVERUSER'
ENV['APPREPO_PASSWORD'] = 'DELIVERPASS'

RSpec.configure do |config|
  config.before(:each) do
    # we do not authenticate against spaceship but apprepo here... where will the ssh session be strongly held?
  end
end

WebMock.disable_net_connect!(allow: 'coveralls.io')

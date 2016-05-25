require 'spec_helper'

require_relative '../lib/apprepo/apprepo.rb'

describe 'AppRepo' do
  it 'should not fail' do
    apprepo = Apprepo.new
  end
end

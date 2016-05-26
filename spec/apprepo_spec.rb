require 'spec_helper'
require 'apprepo'

describe 'apprepo' do
  it 'should not fail' do
    AppRepo.new
  end
end

describe 'init' do
  it 'should not fail' do
  	cgen = AppRepo::CommandsGenerator.new
    cgen.init
  end
end

describe 'submit' do
  it 'should not fail' do
    cgen = AppRepo::CommandsGenerator.new
    cgen.run
  end
 end

 describe 'download_manifest' do
  it 'should not fail' do
    cgen = AppRepo::CommandsGenerator.new
    cgen.download_manifest
  end
 end

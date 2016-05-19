# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apprepo/version'

Gem::Specification.new do |spec|
  spec.name          = "apprepo"
  spec.version       = AppRepo::VERSION
  spec.authors       = ["Matej Sychra", "Felix Krause"]
  spec.email         = ["suculent@me.com"]
  spec.summary       = AppRepo::DESCRIPTION
  spec.description   = AppRepo::DESCRIPTION
  spec.homepage      = "https://github.com/suculent/apprepo"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/apprepo README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # fastlane dependencies
  spec.add_dependency 'fastlane_core', '>= 0.43.1', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'credentials_manager', '>= 0.16.0', '< 1.0.0'
  spec.add_dependency 'spaceship', '>= 0.26.2', '< 1.0.0' # Communication with iTunes Connect
  #spec.add_dependency 'rubygems'
  spec.add_dependency 'net/ssh'
  spec.add_dependency 'net/sftp'

  # third party dependencies
  spec.add_dependency 'fastimage', '~> 1.6' # fetch the image sizes from the screenshots
  spec.add_dependency 'plist', '~> 3.1.0' # for reading the Info.plist of the ipa file

  # Development only  
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency "rubocop", '~> 0.38.0'
  spec.add_development_dependency 'fakefs'
end
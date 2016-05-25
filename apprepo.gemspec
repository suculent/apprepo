# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apprepo/version'

Gem::Specification.new do |spec|
  spec.name          = 'apprepo'
  spec.version       = AppRepo::VERSION
  spec.authors       = ['Felix Krause', 'Matej Sychra']
  spec.email         = ['suculent@me.com']
  spec.summary       = AppRepo::DESCRIPTION
  spec.description   = AppRepo::DESCRIPTION
  spec.homepage      = 'https://github.com/suculent/apprepo'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir['lib/**/*'] + %w( README.md LICENSE )

  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # fastlane dependencies
  spec.add_dependency 'fastlane', '~> 0'
  spec.add_dependency 'fastlane_core', '~> 0'
  spec.add_dependency 'net-ssh', '~> 0'
  spec.add_dependency 'net-sftp', '~> 0'
  spec.add_dependency 'json', '= 1.8.1' # required by fastlane

  # third party dependencies
  spec.add_dependency 'fastimage', '~> 1.6'

  # Development only
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 0.1'
  spec.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.2'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19', '>= 1.19.0'
  spec.add_development_dependency 'coveralls', '~> 0'
  spec.add_development_dependency 'rubocop', '~> 0.38.0'
  spec.add_development_dependency 'fakefs', '~> 0'
  spec.add_development_dependency 'coverband', '~> 0'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cuke_cataloger/version'

Gem::Specification.new do |spec|
  spec.name          = 'cuke_cataloger'
  spec.version       = CukeCataloger::VERSION
  spec.authors       = ['Eric Kessler']
  spec.email         = ['morrow748@gmail.com']
  spec.summary       = 'A tool to give every Cucumber test a unique id'
  spec.description   = 'Scans existing Cucumber tests and updates them to include an id tag that is unique for the test suite.'
  spec.homepage      = 'https://github.com/enkessler/cuke_cataloger'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'cucumber_analytics'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'racatt'
end

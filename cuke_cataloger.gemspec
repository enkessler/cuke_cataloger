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

  spec.required_ruby_version = '>= 2.0', '< 4.0'

  spec.add_runtime_dependency 'cuke_modeler', '>= 0.2', '< 4.0'
  spec.add_runtime_dependency 'cql', '>= 1.0.1', '< 2.0'
  spec.add_runtime_dependency 'rake', '< 14.0'
  spec.add_runtime_dependency 'thor', '< 2.0'

  spec.add_development_dependency "bundler", '< 3'
  spec.add_development_dependency 'cucumber', '< 4.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'racatt', '~> 1.0'
  spec.add_development_dependency 'simplecov', '< 1.0'
  spec.add_development_dependency 'coveralls', '< 1.0'
  spec.add_development_dependency 'rainbow', '< 4.0.0'
end

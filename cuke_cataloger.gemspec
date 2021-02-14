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
  spec.metadata      = {
    'bug_tracker_uri'   => 'https://github.com/enkessler/cuke_cataloger/issues',
    'changelog_uri'     => 'https://github.com/enkessler/cuke_cataloger/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/cuke_cataloger',
    'homepage_uri'      => 'https://github.com/enkessler/cuke_cataloger',
    'source_code_uri'   => 'https://github.com/enkessler/cuke_cataloger'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('', __dir__)) do
    source_controlled_files = `git ls-files -z`.split("\x0")
    source_controlled_files.keep_if { |file| file =~ %r{^(lib|testing/cucumber/features|bin)} }
    source_controlled_files + ['README.md', 'LICENSE.txt', 'CHANGELOG.md', 'cuke_cataloger.gemspec']
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0', '< 4.0'

  spec.add_runtime_dependency 'cuke_modeler', '>= 0.2', '< 4.0'
  spec.add_runtime_dependency 'cql', '>= 1.0.1', '< 2.0'
  spec.add_runtime_dependency 'rake', '>=10.0', '< 14.0'
  spec.add_runtime_dependency 'thor', '< 2.0'

  spec.add_development_dependency 'childprocess', '< 5.0'
  spec.add_development_dependency 'ffi', '< 2.0' # This is an invisible dependency for the `childprocess` gem on Windows
  spec.add_development_dependency "bundler", '< 3'
  spec.add_development_dependency 'cucumber', '< 4.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '< 1.0'
  spec.add_development_dependency 'coveralls', '< 1.0'
  spec.add_development_dependency 'rainbow', '< 4.0.0'
  spec.add_development_dependency 'rubocop', '<= 0.50.0' # RuboCop can not lint against Ruby 2.0 after this version
  spec.add_development_dependency 'yard', '< 1.0'
end

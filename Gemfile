source 'https://rubygems.org'

# Specify your gem's dependencies in cuke_cataloger.gemspec
gemspec


if RUBY_VERSION =~ /^1\.8/
  gem 'cucumber', '<1.3.0'
  gem 'gherkin', '<2.12.0'
  gem 'mime-types', '<2.0.0'
  gem 'rest-client', '<1.7.0'
elsif RUBY_VERSION =~ /^1\./
  gem 'cucumber', '<2.0.0'
end

if RUBY_VERSION !~ /^1\.8/
  # This version of the gem breaks several use cases being tested. The functionality being tested works
  # with any version of gherkin but the tests themselves won't.
  gem 'gherkin', '< 3.0.0'
end

gem 'coveralls', :require => false, :group => :development

source 'http://rubygems.org'

# Specify your gem's dependencies in cuke_cataloger.gemspec
gemspec

# The Coveralls gem can't handle more recent versions of the SimpleCov gem
gem 'simplecov', '<= 0.16.1'

# cuke_cataloger can play with pretty much any version of these but they all play differently with Ruby
if RUBY_VERSION =~ /^1\.8/
  gem 'cucumber', '< 1.3.0'
  gem 'gherkin', '< 2.12.0'
  gem 'mime-types', '< 2.0' # The 'mime-types' gem requires Ruby 1.9.x on/after this version
  gem 'rainbow', '< 2.0' # Ruby 1.8.x support dropped after this version
  gem 'rake', '< 11.0' # Rake dropped 1.8.x support after this version
elsif RUBY_VERSION =~ /^1\./
  gem 'cucumber', '< 2.0.0'
  gem 'mime-types', '< 3.0.0' # The 'mime-types' gem requires Ruby 2.x on/after this version
  gem 'rainbow', '< 3.0' # The 'rainbow' gem requires Ruby 2.x on/after this version
  gem 'rake', '< 12.3.0' # The 'rake' gem requires Ruby 2.x on/after this version
  gem 'rest-client', '< 2.0' # The 'rainbow' gem requires Ruby 2.x on/after this version
end

if RUBY_VERSION =~ /^1\./
  gem 'ffi', '< 1.9.15'  # The 'ffi' gem requires Ruby 2.x on/after this version
  gem 'tins', '< 1.7'    # The 'tins' gem requires Ruby 2.x on/after this version
  gem 'json', '< 2.0'    # The 'json' gem drops pre-Ruby 2.x support on/after this version
  gem 'term-ansicolor', '< 1.4' # The 'term-ansicolor' gem requires Ruby 2.x on/after this version
end

gem 'cuke_modeler', '< 2.0'

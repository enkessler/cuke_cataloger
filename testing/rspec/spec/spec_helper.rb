unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end


require 'tempfile'
require 'cuke_cataloger'


RSpec.configure do |config|
  config.before(:all) do
    here = File.dirname(__FILE__)
    @lib_directory = "#{here}/../../../lib"
  end
end

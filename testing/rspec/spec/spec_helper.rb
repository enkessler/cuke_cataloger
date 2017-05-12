unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end

here = File.dirname(__FILE__)
require "#{here}/../../file_helper"

require 'cuke_cataloger'


RSpec.configure do |config|
  config.before(:all) do
    @lib_directory = "#{here}/../../../lib"
  end
end

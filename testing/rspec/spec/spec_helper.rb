unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end

here = File.dirname(__FILE__)
require "#{here}/../../file_helper"

require 'cuke_cataloger'
require 'pry'


RSpec.configure do |config|
  config.before(:all) do
    @lib_directory = "#{here}/../../../lib"
  end

  config.after(:all) do
    CukeCataloger::FileHelper.created_directories.each do |dir_path|
      FileUtils.remove_entry(dir_path, true)
    end
  end

end

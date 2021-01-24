require 'simplecov'
SimpleCov.command_name('cuke_cataloger-cucumber')

here = File.dirname(__FILE__)
require "#{here}/../../file_helper"

require 'cuke_cataloger'


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

unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end


require 'cuke_cataloger'

here = File.dirname(__FILE__)
require "#{here}/../../file_helper"

PROJECT_ROOT = "#{here}/../../.."
FIXTURE_DIRECTORY = "#{here}/../../fixtures"

Before do
  begin
    @root_test_directory = CukeCataloger::FileHelper.create_directory
  rescue => e
    puts "Error caught in Before hook!"
    puts "Type: #{e.class}"
    puts "Message: #{e.message}"
  end
end

After do
  begin
    `git checkout HEAD -- #{FIXTURE_DIRECTORY}`
  rescue => e
    puts "Error caught in After hook!"
    puts "Type: #{e.class}"
    puts "Message: #{e.message}"
  end
end


at_exit {
  CukeCataloger::FileHelper.created_directories.each do |dir_path|
    FileUtils.remove_entry(dir_path, true)
  end
}

unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end

require 'cuke_cataloger'

here = File.dirname(__FILE__)

DEFAULT_FEATURE_FILE_NAME = 'test_feature'
DEFAULT_FILE_DIRECTORY = "#{here}/../temp_files"
PROJECT_ROOT = "#{here}/../../.."
FIXTURE_DIRECTORY = "#{here}/../../fixtures"

Before do
  begin
    @default_feature_file_name = DEFAULT_FEATURE_FILE_NAME
    @default_file_directory = DEFAULT_FILE_DIRECTORY

    FileUtils.mkdir(@default_file_directory)
  rescue => e
    puts "Error caught in before hook!"
    puts "Type: #{e.class}"
    puts "Message: #{e.message}"
  end
end

After do
  begin
    `git checkout HEAD -- #{FIXTURE_DIRECTORY}`
    FileUtils.remove_dir(@default_file_directory, true)
  rescue => e
    puts "Error caught in before hook!"
    puts "Type: #{e.class}"
    puts "Message: #{e.message}"
  end
end

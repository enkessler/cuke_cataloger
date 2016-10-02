unless RUBY_VERSION.to_s < '1.9.0'
  require 'simplecov'
  SimpleCov.command_name('cuke_cataloger-cucumber')
end

require 'cuke_cataloger'


DEFAULT_FEATURE_FILE_NAME = 'test_feature'
DEFAULT_FILE_DIRECTORY = "#{File.dirname(__FILE__)}/../temp_files"


Before do
  @default_feature_file_name = DEFAULT_FEATURE_FILE_NAME
  @default_file_directory = DEFAULT_FILE_DIRECTORY

  FileUtils.mkdir(@default_file_directory)
end

After do
  FileUtils.remove_dir(@default_file_directory, true)
end

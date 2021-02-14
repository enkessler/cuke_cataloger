ENV['CUKE_CATALOGER_SIMPLECOV_COMMAND_NAME'] ||= 'cucumber_tests'

require 'simplecov'
require_relative 'common_env'

PROJECT_ROOT = "#{__dir__}/.."
FIXTURE_DIRECTORY = "#{__dir__}/../testing/fixtures"

require_relative '../testing/cucumber/step_definitions/action_steps'
require_relative '../testing/cucumber/step_definitions/setup_steps'
require_relative '../testing/cucumber/step_definitions/verification_steps'


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

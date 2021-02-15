ENV['CUKE_CATALOGER_SIMPLECOV_COMMAND_NAME'] ||= 'cucumber_tests'

require 'simplecov'
require_relative 'common_env'

PROJECT_ROOT = "#{__dir__}/..".freeze
FIXTURE_DIRECTORY = "#{__dir__}/../testing/fixtures".freeze

require_relative '../testing/cucumber/step_definitions/action_steps'
require_relative '../testing/cucumber/step_definitions/setup_steps'
require_relative '../testing/cucumber/step_definitions/verification_steps'


Before do
  @root_test_directory = CukeCataloger::FileHelper.create_directory
end

After do
  `git checkout HEAD -- #{FIXTURE_DIRECTORY}`
end


at_exit do
  CukeCataloger::FileHelper.created_directories.each do |dir_path|
    FileUtils.remove_entry(dir_path, true)
  end
end

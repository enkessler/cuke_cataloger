ENV['CUKE_CATALOGER_SIMPLECOV_COMMAND_NAME'] ||= 'rspec_tests'

require 'simplecov'
require_relative 'common_env'


RSpec.configure do |config|

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end


  config.before(:all) do
    @lib_directory = "#{__dir__}/../../../lib"
  end

  config.after(:all) do
    CukeCataloger::FileHelper.created_directories.each do |dir_path|
      FileUtils.remove_entry(dir_path, true)
    end
  end

end

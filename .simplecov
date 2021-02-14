SimpleCov.command_name(ENV['CUKE_CATALOGER_SIMPLECOV_COMMAND_NAME'])

SimpleCov.start do
  root __dir__
  coverage_dir "#{ENV['CUKE_CATALOGER_REPORT_FOLDER']}/coverage"

  add_filter '/testing/'
  add_filter '/environments/'
  add_filter 'cuke_cataloger_helper'

  merge_timeout 300
end

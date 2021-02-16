require 'rake'
require 'cuke_modeler'
require 'cql'


# The top level namespace used by this gem
module CukeCataloger
end


require 'cuke_cataloger/version'
require 'cuke_cataloger/unique_test_case_tagger'
require 'cuke_cataloger/rake_tasks'
require 'cuke_cataloger/formatters/text_report_formatter'

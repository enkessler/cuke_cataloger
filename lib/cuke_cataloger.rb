require 'rake'
require 'cuke_modeler'
require 'cql'

require 'cuke_cataloger/version'
require 'cuke_cataloger/unique_test_case_tagger'

module CukeCataloger

  extend Rake::DSL

  # todo - test these better

  def self.create_tasks

    desc 'Add unique id tags to tests in the given directory'
    task 'tag_tests', [:directory, :prefix, :row_id, :id_column_name] do |t, args|
      location = args[:directory] || '.'
      prefix = args[:prefix] || '@test_case_'
      tag_rows = args[:row_id].nil? ? true : args[:row_id]
      id_column_name = args[:id_column_name] || 'test_case_id'

      puts "Tagging tests in '#{location}' with tag '#{prefix}'\n"
      puts "Including outline rows\n" if tag_rows

      tagger = CukeCataloger::UniqueTestCaseTagger.new
      tagger.tag_tests(location, prefix, {}, tag_rows, id_column_name)
    end

    desc 'Scan tests in the given directory for id problems'
    task 'validate_tests', [:directory, :prefix, :out_file, :row_id, :id_column_name] do |t, args|
      location = args[:directory] || '.'
      prefix = args[:prefix] || '@test_case_'
      tag_rows = args[:row_id].nil? ? true : args[:row_id]
      id_column_name = args[:id_column_name] || 'test_case_id'

      puts "Validating tests in '#{location}' with tag '#{prefix}'\n"
      puts "Including outline rows\n" if tag_rows

      results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(location, prefix, tag_rows, id_column_name)
      report_text = "Validation Results\nProblems found: #{results.count}\n\n"


      results_by_category = Hash.new { |hash, key| hash[key] = [] }

      results.each do |result|
        results_by_category[result[:problem]] << result
      end

      results_by_category.keys.each do |problem_category|
        report_text << "#{problem_category} problems: #{results_by_category[problem_category].count}\n"
      end

      results_by_category.keys.each do |problem_category|
        report_text << "\n\n#{problem_category} problems (#{results_by_category[problem_category].count}):\n"

        results_by_category[problem_category].each do |result|
          report_text << "#{result[:test]}\n"
        end
      end

      if args[:out_file]
        puts "Problems found: #{results.count}"
        File.open(args[:out_file], 'w') { |file| file.write(report_text) }
      else
        puts report_text
      end
    end

  end

end

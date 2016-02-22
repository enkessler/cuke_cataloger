require 'rake'
require 'cuke_modeler'
require 'cql'

require 'cuke_cataloger/version'
require 'cuke_cataloger/unique_test_case_tagger'

module CukeCataloger

  extend Rake::DSL


  def self.create_tasks

    desc 'Add unique id tags to tests in the given directory'
    task 'tag_tests', [:directory, :prefix] do |t, args|
      puts "Tagging tests in '#{args[:directory]}' with tag '#{args[:prefix]}'\n"

      tagger = CukeCataloger::UniqueTestCaseTagger.new
      tagger.tag_tests(args[:directory], args[:prefix])
    end

    desc 'Scan tests in the given directory for id problems'
    task 'validate_tests', [:directory, :prefix, :out_file] do |t, args|
      puts "Validating tests in '#{args[:directory]}' with tag '#{args[:prefix]}'\n"

      results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(args[:directory], args[:prefix])
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
        File.write(args[:out_file], report_text)
      else
        puts report_text
      end
    end

  end

end

# TODO: have better testing so that this can be safely refactored
# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/LineLength, Metrics/MethodLength, Metrics/PerceivedComplexity - Not going to mess with this, given how little testing is present


# The top level namespace used by this gem
module CukeCataloger

  extend Rake::DSL


  # Adds the gem's provided Rake tasks to the namespace from which the method is called
  def self.create_tasks
    desc 'Add unique id tags to tests in the given directory'
    task 'tag_tests', [:directory, :prefix, :row_id, :id_column_name] do |_t, args|
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
    task 'validate_tests', [:directory, :prefix, :out_file, :row_id, :id_column_name] do |_t, args|
      location = args[:directory] || '.'
      prefix = args[:prefix] || '@test_case_'
      tag_rows = args[:row_id].nil? ? true : args[:row_id]
      id_column_name = args[:id_column_name] || 'test_case_id'

      puts "Validating tests in '#{location}' with tag '#{prefix}'\n"
      puts "Including outline rows\n" if tag_rows

      results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(location, prefix, tag_rows, id_column_name)
      report_text = CukeCataloger::TextReportFormatter.new.format_data(results)

      if args[:out_file]
        puts "Problems found: #{results.count}"
        File.open(args[:out_file], 'w') { |file| file.write(report_text) }
      else
        puts report_text
      end
    end
  end

end

# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/LineLength, Metrics/MethodLength, Metrics/PerceivedComplexity

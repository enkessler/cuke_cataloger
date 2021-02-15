Then(/^the resulting file(?: "([^"]*)")? is:$/) do |file_index, expected_text|
  file_index ||= 1
  file_name = @feature_files[file_index.to_i - 1]

  actual_text = File.read(file_name)

  expect(actual_text).to eq(expected_text)
end

Then(/^the following tests are found to be missing ids:$/) do |expected_tests|
  verify_category_results(:missing_tag, expected_tests)
end

Then(/^no tests are found to be missing ids$/) do
  verify_no_results
end

Then(/^the following tests rows are found to be missing sub ids:$/) do |expected_rows|
  verify_category_results(:missing_row_id, expected_rows)
end

Then(/^no tests rows are found to be missing sub ids$/) do
  verify_no_results
end

Then(/^the following tests examples are found to be missing a parameter for sub ids:$/) do |expected_examples|
  verify_category_results(:missing_id_column, expected_examples)
end

Then(/^no test examples are found to be missing id parameters$/) do
  verify_no_results
end

Then(/^the following tests example rows are found to have mismatched sub ids:$/) do |expected_rows|
  verify_category_results(:mismatched_row_id, expected_rows)
end

Then(/^no test example rows are found to have mismatched ids$/) do
  verify_no_results
end

Then(/^the following tests are found to have multiple test ids:$/) do |expected_tests|
  verify_category_results(:multiple_tags, expected_tests)
end

Then(/^no tests are found to have multiple test ids$/) do
  verify_no_results
end

Then(/^the following tests are found to have a duplicated id:$/) do |expected_tests|
  verify_category_results(:duplicate_id_tag, expected_tests)
end

Then(/^no tests are found to have duplicated ids$/) do
  verify_no_results
end

Then(/^the following tests example rows are found to have duplicated sub ids:$/) do |expected_rows|
  verify_category_results(:duplicate_row_id, expected_rows)
end

Then(/^no test example rows are found to have duplicated sub ids$/) do
  verify_no_results
end

Then(/^the following tests example rows are found to have malformed sub ids:$/) do |expected_rows|
  verify_category_results(:malformed_sub_id, expected_rows)
end

Then(/^no test example rows are found to have malformed sub ids$/) do
  verify_no_results
end

Then(/^the following tagged test objects are found:$/) do |expected_results|
  verify_results(expected_results)
end

Then(/^the payload is a model object$/) do
  class_name = @test_results.first[:object].class.name.split('::').last

  expect(CukeModeler.const_defined?(class_name)).to be true
end

Then(/^the payload has a test and a test row$/) do
  expect(@test_results[0][:object]).to be_a_kind_of(CukeModeler::Outline)
  expect(@test_results[1][:object]).to be_a_kind_of(CukeModeler::Row)
end

Then(/^the following ids are found:$/) do |expected_ids|
  expect(@ids_found).to match_array(expected_ids.raw.flatten)
end

Then(/^the following feature is found to have a test case tag:$/) do |expected_results|
  verify_category_results(:feature_test_tag, expected_results)
end

Then(/^no feature is found to have a test case tag$/) do
  verify_no_results
end

Then(/^the column for sub-ids is placed after all other columns$/) do
  file_model = CukeModeler::FeatureFile.new(@feature_files.first)
  outline_model = file_model.feature.outlines.first

  expect(outline_model.examples.first.parameters.last).to eq('test_case_id')
end


def verify_no_results
  expect(@test_results).to be_empty
end

def verify_category_results(category, results)
  @test_results = @test_results.select { |test_result| test_result[:problem] == category }
  verify_results(results)
end

def verify_results(results)
  actual = @test_results.collect { |test_result| test_result[:test] }
  expected = process_expected_results(results)

  expect(actual).to match_array(expected)
end

def process_expected_results(results)
  results = results.raw.flatten
  results.collect { |test_path| test_path.sub('path/to', @root_test_directory) }
end


Then(/^the resulting first file is:$/) do |expected_text|
  file_name = @feature_files[0]

  actual_text = File.read(file_name)

  # The order in which Ruby returns files varies across version and operating system. This, in turn, will
  # affect the order in which files are tagged. Either order is acceptable as long as the tagging is
  # consistent for any given ordering.
  begin
    expect(actual_text).to eq(expected_text)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    raise e unless RUBY_PLATFORM =~ /(?:linux|java)/

    expected_text.sub!('test_case_1', 'test_case_2')
    expect(actual_text).to eq(expected_text)
    @switched = true
  end

end

And(/^the resulting second file is:$/) do |expected_text|
  file_name = @feature_files[1]

  actual_text = File.read(file_name)

  # The order in which Ruby returns files various across version and operating system. This, in turn, will
  # affect the order in which files are tagged. Either order is acceptable as long as the tagging is
  # consistent for any given ordering.
  if @switched
    expected_text.sub!('test_case_2', 'test_case_1')
    expected_text.sub!('2-1', '1-1')
    expected_text.sub!('2-2', '1-2')
  end

  expect(actual_text).to eq(expected_text)
end

Then(/^all of the test cases in the "([^"]*)" directory will be cataloged with "([^"]*)"$/) do |target_directory, prefix| # rubocop:disable Metrics/LineLength
  target_directory = "#{FIXTURE_DIRECTORY}/#{target_directory}"

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(target_directory, prefix)

  verify_no_results
end

Then(/^all of the scenarios and outlines in the "([^"]*)" directory will be cataloged with "([^"]*)"$/) do |target_directory, prefix| # rubocop:disable Metrics/LineLength
  target_directory = "#{FIXTURE_DIRECTORY}/#{target_directory}"
  @expected_prefix = prefix
  tag_rows = false

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(target_directory, @expected_prefix, tag_rows) # rubocop:disable Metrics/LineLength

  verify_no_results
end

But(/^outline rows in the "([^"]*)" directory are not cataloged$/) do |target_directory|
  target_directory = "#{FIXTURE_DIRECTORY}/#{target_directory}"
  tag_rows = true

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(target_directory, @expected_prefix, tag_rows) # rubocop:disable Metrics/LineLength

  expect(@test_results.collect { |result| result[:problem] }).to include(:missing_id_column)
end

Then(/^a validation report for the "([^"]*)" directory with prefix "([^"]*)" is output to the console$/) do |target_directory, prefix| # rubocop:disable Metrics/LineLength
  expect(@output).to include("Validating tests in '#{target_directory}' with tag '#{prefix}'")
  expect(@output).to include('Validation Results')
end

Then(/^a validation report for the "([^"]*)" directory with prefix "([^"]*)" is output to "([^"]*)"$/) do |target_directory, prefix, filename| # rubocop:disable Metrics/LineLength
  target_directory = "#{FIXTURE_DIRECTORY}/#{target_directory}"
  filename = "#{@root_test_directory}/#{filename}"

  expect(@output).to include("Validating tests in '#{target_directory}' with tag '#{prefix}'")
  expect(@output).to include('Problems found:')

  expect(File.exist?(filename)).to be true
  expect(File.read(filename)).to include('Validation Results')
end

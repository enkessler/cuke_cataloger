Then(/^the resulting file(?: "([^"]*)")? is:$/) do |file_index, expected_text|
  file_index ||= 1
  file_name = @feature_files[file_index - 1]

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

Then(/^the payload is a test object$/) do
  expect(@test_results.first[:object]).to be_a_kind_of(CucumberAnalytics::TestElement)
end

Then(/^the payload has a test and a test row$/) do
  expect(@test_results[0][:object]).to be_a_kind_of(CucumberAnalytics::Outline)
  expect(@test_results[1][:object]).to be_a_kind_of(CucumberAnalytics::Row)
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
  file_model = CucumberAnalytics::FeatureFile.new(@feature_files.first)
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
  expect(@test_results.collect { |test_result| test_result[:test] }).to match_array(process_results(results))
end

def process_results(results)
  results = results.raw.flatten
  results.collect { |test_path| test_path.sub('path/to', @default_file_directory) }
end

Then(/^the resulting first file is:$/) do |expected_text|
  file_name = @feature_files[0]

  # The order in which Ruby returns files various across verion and operating system. This, in turn. will affect the order in which files are tagged.
  if (RUBY_PLATFORM =~ /linux/) && (!['2.1.6'].include?(RUBY_PLATFORM))
    expected_text.sub!('test_case_1', 'test_case_2')
  end

  actual_text = File.read(file_name)

  expect(actual_text).to eq(expected_text)
end

And(/^the resulting second file is:$/) do |expected_text|
  file_name = @feature_files[1]

  # The order in which Ruby returns files various across verion and operating system. This, in turn. will affect the order in which files are tagged.
  if (RUBY_PLATFORM =~ /linux/) && (!['2.1.6'].include?(RUBY_PLATFORM))
    expected_text.sub!('test_case_2', 'test_case_1')
    expected_text.sub!('2-1', '1-1')
    expected_text.sub!('2-2', '1-2')
  end

  actual_text = File.read(file_name)

  expect(actual_text).to eq(expected_text)
end

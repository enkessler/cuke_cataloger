Given /^the following feature file(?: "([^"]*)")?:$/ do |file_name, file_text|
  @test_directory = @root_test_directory
  @files_created ||= 0
  @feature_files ||= []

  file_name ||= "test_feature_#{@files_created + 1}"
  file_name = File.basename(file_name, '.feature')

  file_path = CukeCataloger::FileHelper.create_feature_file(:directory => @test_directory, :name => file_name, :text => file_text)
  @feature_files << file_path

  @files_created += 1
end

When(/^a tag prefix of "([^"]*)"$/) do |prefix|
  @tag_prefix = prefix
end

And(/^a start index of "([^"]*)"$/) do |index|
  @start_index ||= {:sub => {}}
  @start_index[:primary] = index
end

And(/^a start index of "([^"]*)" for testcase "([^"]*)"$/) do |sub_index, parent_index|
  @start_index ||= {:sub => {}}
  @start_index[:sub][parent_index.to_s] = sub_index
end

Given(/^a feature file$/) do
  @test_directory = @root_test_directory
  @files_created ||= 0
  @feature_files ||= []

  file_name = "test_feature_#{@files_created + 1}.feature"
  file_name = File.basename(file_name, '.feature')

  file_text = "Feature:\nScenario Outline:\n* a step\nExamples:\n| param 1 |\n| value 1 |"

  file_path = CukeCataloger::FileHelper.create_feature_file(:directory => @test_directory, :name => file_name, :text => file_text)
  @feature_files << file_path

  @files_created += 1
end

And(/^the tag should be at the "([^"]*)"$/) do |tag_location|
  case tag_location
    when 'top'
      @above_or_below = :above
    when 'bottom'
      @above_or_below = :below
    when 'side'
      @above_or_below = :adjacent
  end
end

And(/^the tag location is unspecified$/) do
  @above_or_below = nil
end

Given(/^the cuke_cataloger executable is available$/) do
  @executable_directory = "#{PROJECT_ROOT}/bin"
end

And(/^there are test cases in the "([^"]*)" directory that have not been cataloged with "([^"]*)"$/) do |target_directory, prefix|
  target_directory = "#{FIXTURE_DIRECTORY}/#{target_directory}"

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(target_directory, prefix)

  # Making sure that there is work to be done, thus avoiding false positives
  expect(@test_results.select { |test_result| test_result[:problem] == :missing_tag }).to_not be_empty
end

Given(/^the Rake tasks provided by the gem have been loaded$/) do
  File.open("#{FIXTURE_DIRECTORY}/Rakefile", 'a') { |file| file.puts 'CukeCataloger.create_tasks' }
  CukeCataloger.create_tasks
end

Given /^the following feature file(?: "([^"]*)")?:$/ do |file_name, file_text|
  @test_directory = @default_file_directory
  @files_created ||= 0
  @feature_files ||= []

  file_name ||= "#{@default_feature_file_name}_#{@files_created + 1}.feature"
  file_path = "#{@test_directory}/#{file_name}"
  @feature_files << file_path

  File.open(file_path, 'w') { |file| file.write file_text }

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
  @test_directory = @default_file_directory
  @files_created ||= 0
  @feature_files ||= []

  file_name ||= "#{@default_feature_file_name}_#{@files_created + 1}.feature"
  file_path = "#{@test_directory}/#{file_name}"
  @feature_files << file_path

  File.open(file_path, 'w') { |file| file.write "Feature:\nScenario Outline:\n* a step\nExamples:\n| param 1 |\n| value 1 |" }

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

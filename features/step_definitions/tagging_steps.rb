Given /^the following feature file:$/ do |file_text|
  @files_created ||= 0

  @test_directory = @default_file_directory
  file_name = "#{@default_feature_file_name}_#{@files_created + 1}.feature"

  File.open("#{@test_directory}/#{file_name}", 'w') { |file|
    file.write(file_text)
  }

  @files_created += 1
end

When(/^a tag prefix of "([^"]*)"$/) do |prefix|
  @tag_prefix = prefix
end

When(/^the files? (?:is|are) processed$/) do
  directory = CucumberAnalytics::Directory.new(@test_directory)

  @feature_files = directory.feature_files.collect { |file| file.path }

  UniqueTestCaseTagger.new.tag_tests(directory.path, @tag_prefix)
end

Then(/^the resulting file(?: "([^"]*)")? is:$/) do |file_index, expected_text|
  file_index ||= 1

  actual_text = File.open(@feature_files[file_index - 1], 'r') { |file| actual_text = file.read }

  actual_text.should == expected_text
end

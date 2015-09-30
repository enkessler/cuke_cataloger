When(/^the files? (?:is|are) processed$/) do
  @start_index ||= {}
  @directory = CucumberAnalytics::Directory.new(@test_directory)

  tagger = CukeCataloger::UniqueTestCaseTagger.new
  tagger.tag_location = @above_or_below if @above_or_below

  tagger.tag_tests(@directory.path, @tag_prefix, @start_index)
end

When(/^the ids in the test suite are validated$/) do
  @directory = CucumberAnalytics::Directory.new(@test_directory)

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.validate_test_ids(@directory.path, @tag_prefix)
end

When(/^the files are scanned$/) do
  @directory = CucumberAnalytics::Directory.new(@test_directory)
  @exception_raised = false

  @test_results = CukeCataloger::UniqueTestCaseTagger.new.scan_for_tagged_tests(@directory.path, @tag_prefix)
end

When(/^the existing ids are determined$/) do
  @directory = CucumberAnalytics::Directory.new(@test_directory)

  @ids_found = CukeCataloger::UniqueTestCaseTagger.new.determine_known_ids(@directory.path, @tag_prefix)
end

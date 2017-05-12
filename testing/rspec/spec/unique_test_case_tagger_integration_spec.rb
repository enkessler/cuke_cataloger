require "#{File.dirname(__FILE__)}/spec_helper"


describe 'UniqueTestCaseTagger, Integration' do

  clazz = CukeCataloger::UniqueTestCaseTagger

  before(:each) do
    @tagger = clazz.new
  end

  describe 'test tagging' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it tags tests' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, {0 => '123', 2 => '456'})

      Dir.mktmpdir { |path| @tagger.tag_tests(path, '') }

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

  end

  describe 'data validation' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it validates test ids' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, {0 => '123', 2 => '456'})

      Dir.mktmpdir { |path| @tagger.validate_test_ids(path, '') }

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

  end

  describe 'test scanning' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it scans for tagged tests' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, {0 => '123', 2 => '456'})

      Dir.mktmpdir { |path| @tagger.scan_for_tagged_tests(path, '') }

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end
  end

  describe 'tag indexing' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it determines known test ids' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, {0 => '123', 2 => '456'})

      Dir.mktmpdir { |path| @tagger.determine_known_ids(path, '') }

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

    it 'does not count id like values that are not in the specified id column' do
      test_directory = Dir.mktmpdir

      text = "Feature:

                @test_case_1
                Scenario:
                  * a step

                @test_case_2
                Scenario Outline:
                  * a step with a <param>
                  Examples: with rows
                    | param   | test_case_id | foobar |
                    | value 1 | 2-1          | 2-4    |
                  Examples: without rows
                    | param   | test_case_id | foobar |
                    | value 1 | 2-2          | 2-5    |
                    | value 2 | 2-3          | 2-6    |

                @test_case_3
                Scenario:
                  * a step"

      CukeCataloger::FileHelper.create_feature_file(:directory => test_directory, :text => text)


      result = @tagger.determine_known_ids(test_directory, '@test_case_', 'foobar')


      expect(result).to_not include('2-1', '2-2', '2-3')
    end

  end

end

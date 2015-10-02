require 'spec_helper'

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

      @tagger.tag_tests(@default_file_directory, '')

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

      @tagger.validate_test_ids(@default_file_directory, '')

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

      @tagger.scan_for_tagged_tests(@default_file_directory, '')

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

      @tagger.determine_known_ids(@default_file_directory, '')

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end
  end

end

require 'spec_helper'

describe 'UniqueTestCaseTagger, Unit', unit: true do

  clazz = CukeCataloger::UniqueTestCaseTagger

  before(:each) do
    @tagger = clazz.new
  end

  describe 'test tagging' do
    it "can tag a suite's tests" do
      @tagger.should respond_to(:tag_tests)
    end

    it 'takes a directory, tag prefix, and an optional start index' do
      @tagger.method(:tag_tests).arity.should == -3
    end
  end

  describe 'data validation' do
    it "can check the validity of a suite's test ids" do
      @tagger.should respond_to(:validate_test_ids)
    end

    it 'requires a directory and tag prefix when validating' do
      @tagger.method(:validate_test_ids).arity.should == 2
    end

    it 'returns validation results' do
      @tagger.validate_test_ids(@default_file_directory, '').is_a?(Array).should be true
    end
  end

  describe 'test scanning' do
    it "can scan for tagged tests" do
      @tagger.should respond_to(:scan_for_tagged_tests)
    end

    it 'requires a directory and tag prefix when validating' do
      @tagger.method(:scan_for_tagged_tests).arity.should == 2
    end

    it 'returns scanning results' do
      @tagger.scan_for_tagged_tests(@default_file_directory, '').is_a?(Array).should be true
    end
  end

  describe 'tag indexing' do
    it "can determine used test case indexes" do
      @tagger.should respond_to(:determine_known_ids)
    end

    it 'requires a directory and tag prefix when determining used indexes' do
      @tagger.method(:determine_known_ids).arity.should == 2
    end
  end

  describe 'formatting' do
    it 'has a tag location' do
      @tagger.should respond_to(:tag_location)
    end

    it 'can change its tag location' do
      @tagger.should respond_to(:tag_location=)

      @tagger.tag_location = :some_flag_value
      @tagger.tag_location.should == :some_flag_value
      @tagger.tag_location = :some_other_flag_value
      @tagger.tag_location.should == :some_other_flag_value
    end
  end

end

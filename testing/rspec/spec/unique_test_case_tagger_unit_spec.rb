require_relative '../../../environments/rspec_env'


RSpec.describe 'UniqueTestCaseTagger, Unit' do

  clazz = CukeCataloger::UniqueTestCaseTagger

  before(:each) do
    @tagger = clazz.new
  end

  describe 'test tagging' do
    it "can tag a suite's tests" do
      expect(@tagger).to respond_to(:tag_tests)
    end

    it 'takes a directory, optional tag prefix, and an optional start index' do
      expect(@tagger.method(:tag_tests).arity).to eq(-2)
    end
  end

  describe 'data validation' do
    it "can check the validity of a suite's test ids" do
      expect(@tagger).to respond_to(:validate_test_ids)
    end

    it 'validates based on a directory, optional tag prefix, and optional row tagging flag' do
      expect(@tagger.method(:validate_test_ids).arity).to eq(-2)
    end

    it 'returns validation results' do
      path = CukeCataloger::FileHelper.create_directory
      results = @tagger.validate_test_ids(path, '')

      expect(results).to be_a_kind_of(Array)
    end
  end

  describe 'test scanning' do
    it 'can scan for tagged tests' do
      expect(@tagger).to respond_to(:scan_for_tagged_tests)
    end

    it 'validates based on a directory, optional tag prefix, and optional column name' do
      expect(@tagger.method(:scan_for_tagged_tests).arity).to eq(-2)
    end

    it 'returns scanning results' do
      path = CukeCataloger::FileHelper.create_directory
      results = @tagger.scan_for_tagged_tests(path, '')

      expect(results).to be_a_kind_of(Array)
    end
  end

  describe 'tag indexing' do
    it 'can determine used test case indexes' do
      expect(@tagger).to respond_to(:determine_known_ids)
    end

    it 'determines used indexes based on a directory, optional tag prefix, and optional column name' do
      expect(@tagger.method(:determine_known_ids).arity).to eq(-2)
    end
  end

  describe 'formatting' do
    it 'has a tag location' do
      expect(@tagger).to respond_to(:tag_location)
    end

    it 'can change its tag location' do
      expect(@tagger).to respond_to(:tag_location=)

      @tagger.tag_location = :some_flag_value
      expect(@tagger.tag_location).to eq(:some_flag_value)
      @tagger.tag_location = :some_other_flag_value
      expect(@tagger.tag_location).to eq(:some_other_flag_value)
    end
  end

end

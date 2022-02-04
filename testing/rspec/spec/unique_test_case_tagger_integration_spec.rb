require_relative '../../../environments/rspec_env'


RSpec.describe 'UniqueTestCaseTagger, Integration' do

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
      @tagger.instance_variable_set(:@known_id_tags, 0 => '123', 2 => '456')

      path = CukeCataloger::FileHelper.create_directory
      @tagger.tag_tests(path, '')

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

    it 'uses a default tag prefix' do
      test_directory = CukeCataloger::FileHelper.create_directory

      starting_text = 'Feature:

                         Scenario:
                           * a step'

      test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: starting_text)


      @tagger.tag_tests(test_directory)

      expected_text = 'Feature:

                         @test_case_1
                         Scenario:
                           * a step'

      tagged_text = File.read(test_file)


      expect(tagged_text).to eq(expected_text)
    end

    it 'uses a default id column name' do
      test_directory = CukeCataloger::FileHelper.create_directory

      starting_text = 'Feature:

                         Scenario Outline:
                           * a step
                         Examples:
                           | param |
                           | value |'

      test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: starting_text)


      @tagger.tag_tests(test_directory)

      expected_text = 'Feature:

                         @test_case_1
                         Scenario Outline:
                           * a step
                         Examples:
                           | param | test_case_id |
                           | value | 1-1          |'

      tagged_text = File.read(test_file)


      expect(tagged_text).to eq(expected_text)
    end

    # The exact order that the underlying AST is walked through might change (like it did when rules were introduced
    # and nested tests became a thing), resulting in the collection of gathered models not having tests from the same
    # file adjacent to each other (due to undefined behavior for sorting models with equal source line numbers but from
    # different files) or even tests within the same file in a different order than they appear in the file (due to the
    # aforementioned nesting).
    #
    # TODO: Make it official that files will be processed alphabetically and from top to bottom?
    it "doesn't assume that tests will be discovered 'in order' within a file" do
      begin
        CukeCataloger::HelperMethods.test_storage[:old_method] = CQL::Queriable.instance_method(:query)

        # Monkey patch the query method so that we can ensure that the models are not 'in order'
        module CQL
          module Queriable
            def query(&block)
              # Perform the query as usual
              result = CukeCataloger::HelperMethods.test_storage[:old_method].bind(self).call(&block)

              # But then mess with the model order
              result.shuffle!

              result
            end
          end
        end


        test_directory = CukeCataloger::FileHelper.create_directory

        starting_text = 'Feature:

                         Scenario:
                           * a step

                         Scenario:
                           * a step

                         Scenario:
                           * a step'

        test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: starting_text)


        @tagger.tag_tests(test_directory)

        expected_text = 'Feature:

                         @test_case_1
                         Scenario:
                           * a step

                         @test_case_2
                         Scenario:
                           * a step

                         @test_case_3
                         Scenario:
                           * a step'

        tagged_text = File.read(test_file)


        expect(tagged_text).to eq(expected_text)
      ensure
        # Making sure that our changes don't escape a test and ruin the rest of the suite
        module CQL
          module Queriable
            define_method(:query, CukeCataloger::HelperMethods.test_storage[:old_method])
          end
        end
      end
    end

    # See comment for previous test
    it 'tags an entire file before moving on to the next one' do
      begin
        CukeCataloger::HelperMethods.test_storage[:old_method] = CQL::Queriable.instance_method(:query)

        # Monkey patch the query method so that we can ensure that the models are not 'in order'
        module CQL
          module Queriable
            def query(&block)
              # Perform the query as usual
              result = CukeCataloger::HelperMethods.test_storage[:old_method].bind(self).call(&block)

              # But then mess with the model order
              result.shuffle!

              result
            end
          end
        end


        starting_file_1_text = 'Feature:

                                  Scenario:
                                    * a step

                                  Scenario:
                                    * a step

                                  Scenario:
                                    * a step'

        starting_file_2_text = 'Feature:

                                  Scenario:
                                    * a step

                                  Scenario:
                                    * a step

                                  Scenario:
                                    * a step'

        test_directory = CukeCataloger::FileHelper.create_directory
        test_file_1 = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: starting_file_1_text, name: 'file_1')
        test_file_2 = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: starting_file_2_text, name: 'file_2')


        @tagger.tag_tests(test_directory)

        expected_text_1 = 'Feature:

                             @test_case_1
                             Scenario:
                               * a step

                             @test_case_2
                             Scenario:
                               * a step

                             @test_case_3
                             Scenario:
                               * a step'

        expected_text_2 = 'Feature:

                             @test_case_4
                             Scenario:
                               * a step

                             @test_case_5
                             Scenario:
                               * a step

                             @test_case_6
                             Scenario:
                               * a step'

        tagged_text_1 = File.read(test_file_1)
        tagged_text_2 = File.read(test_file_2)


        # Squeezing to avoid irrelevant whitespace differences due to indentation of test data
        expect(tagged_text_1.squeeze).to eq(expected_text_1.squeeze)
        expect(tagged_text_2.squeeze).to eq(expected_text_2.squeeze)
      ensure
        # Making sure that our changes don't escape a test and ruin the rest of the suite
        module CQL
          module Queriable
            define_method(:query, CukeCataloger::HelperMethods.test_storage[:old_method])
          end
        end
      end
    end

  end

  describe 'data validation' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it validates test ids' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, 0 => '123', 2 => '456')

      path = CukeCataloger::FileHelper.create_directory
      @tagger.validate_test_ids(path, '')

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

    it 'uses a default tag prefix' do
      test_directory = CukeCataloger::FileHelper.create_directory

      gherkin_text = 'Feature:

                        @test_case_1
                        Scenario:
                          * a step'

      CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: gherkin_text)


      results = @tagger.validate_test_ids(test_directory)

      expect(results).to be_empty
    end

    it 'uses a default id column name' do
      test_directory = CukeCataloger::FileHelper.create_directory

      gherkin_text = 'Feature:

                        @test_case_1
                        Scenario Outline:
                          * a step
                        Examples:
                          | param   | test_case_id |
                          | value 1 |  1-1         |'

      CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: gherkin_text)


      results = @tagger.validate_test_ids(test_directory)

      expect(results).to be_empty
    end
  end

  describe 'test scanning' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it scans for tagged tests' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, 0 => '123', 2 => '456')

      path = CukeCataloger::FileHelper.create_directory
      @tagger.scan_for_tagged_tests(path, '')

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

    it 'uses a default tag prefix' do
      test_directory = CukeCataloger::FileHelper.create_directory

      gherkin_text = 'Feature:

                        @test_case_1
                        Scenario:
                          * a step'

      test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: gherkin_text)


      results = @tagger.scan_for_tagged_tests(test_directory)


      expect(results.collect { |result| result[:test] }).to eq(["#{test_file}:4"])
    end

    it 'uses a default id column name' do
      test_directory = CukeCataloger::FileHelper.create_directory

      gherkin_text = 'Feature:

                        @test_case_1
                        Scenario Outline:
                          * a step
                        Examples:
                          | param   | test_case_id |
                          | value 1 |  1-1         |'

      test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: gherkin_text)


      results = @tagger.scan_for_tagged_tests(test_directory)

      expect(results.collect { |result| result[:test] }).to eq(["#{test_file}:4",
                                                                "#{test_file}:8"])
    end

    it 'only considers tags that match the prefix+number pattern' do
      test_directory = CukeCataloger::FileHelper.create_directory
      gherkin_text = 'Feature:

                        @test_case_1
                        Scenario:
                          * a step

                        # Extra characters at the beginning
                        @not_test_case_2
                        Scenario:
                          * a step

                        # Extra characters at the end
                        @test_case_2_but_not_really
                        Scenario:
                          * a step

                        @test_case_2
                        Scenario:
                          * a step'
      test_file = CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: gherkin_text)

      results = @tagger.scan_for_tagged_tests(test_directory)

      expect(results.collect { |result| result[:test] }).to match_array(["#{test_file}:4",
                                                                         "#{test_file}:18"])
    end

  end

  describe 'tag indexing' do

    # Bug fix - The #object_id of an object is used to track whether or not an id is already known or not for a
    # particular test. Some ids may already have been stored from previous method calls and, if the memory from those
    # previous calls is reassigned to new objects, this could result in test ids being associated with tests that don't
    # have them.

    it 'clears its known ids when it determines known test ids' do
      # Using ids that are not used for memory allocation by Ruby since they are used for predefined constants.
      @tagger.instance_variable_set(:@known_id_tags, 0 => '123', 2 => '456')

      path = CukeCataloger::FileHelper.create_directory
      @tagger.determine_known_ids(path, '')

      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(0)
      expect(@tagger.instance_variable_get(:@known_id_tags)).to_not include(1)
    end

    it 'does not count id like values that are not in the specified id column' do
      test_directory = CukeCataloger::FileHelper.create_directory

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

      CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: text)


      result = @tagger.determine_known_ids(test_directory, '@test_case_', 'foobar')


      expect(result).to_not include('2-1', '2-2', '2-3')
    end

    it 'uses a default tag prefix' do
      test_directory = CukeCataloger::FileHelper.create_directory

      text = 'Feature:

                @test_case_1
                Scenario:
                  * a step'

      CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: text)


      result = @tagger.determine_known_ids(test_directory)


      expect(result).to eq(['1'])
    end

    it 'uses a default id column name' do
      test_directory = CukeCataloger::FileHelper.create_directory

      text = 'Feature:

                @test_case_1
                Scenario Outline:
                  * a step
                Examples:
                  | param | test_case_id |
                  | value | 1-1          |'

      CukeCataloger::FileHelper.create_feature_file(directory: test_directory, text: text)


      result = @tagger.determine_known_ids(test_directory)


      expect(result).to eq(['1', '1-1'])
    end

  end

end

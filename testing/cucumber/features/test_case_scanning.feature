Feature: Scanning for tagged test cases

  The test tagger is capable of finding all existing test objects within a test suite that have an id.


  Scenario: Finds all tagged tests
    Given the following feature file "file1.feature":
    """
    Feature:

      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step

      @test_case_7
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 7-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
      Examples: with empty rows
        | test_case_id | param 1 |
        |              | value 1 |
        | 7-2          | value 2 |
      Examples: without an id parameter
        | param 1 |
        | value 1 |

      #Missing the parent tag but the sub-tags still count
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 8-1          | value 1 |
        | trash        | value 1 |
    """
    And the following feature file "file2.feature":
    """
    Feature: Just another feature to make sure that the entire suite is checked

      @test_case_5
      Scenario:
        * a step
    """
    And a tag prefix of "@test_case_"
    When the files are scanned
    Then the following tagged test objects are found:
      | path/to/file1.feature:7  |
      | path/to/file1.feature:11 |
      | path/to/file1.feature:15 |
      | path/to/file1.feature:21 |
      | path/to/file1.feature:31 |
      | path/to/file1.feature:32 |
      | path/to/file2.feature:4  |

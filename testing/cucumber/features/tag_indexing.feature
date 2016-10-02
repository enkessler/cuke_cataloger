Feature: Tag indexing

  The tool is capable of determining which indexes are already in use in a test suite. If no other set of indexes is
  provided, these existing indexes are what will be used to pick what indexes the tool will start with when tagging.
  Using this default, new indexes start after the highest found index so as not to repeat the indexes of older tests
  that might have since been removed. This default behavior can be overridden by providing an initial index from which
  to start tagging.

  An analogous principle is used for outlines.


  Background:
    * a tag prefix of "@test_case_"

  Scenario: Used indexes can be determined
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
      Examples: with a non-indexed id
        | test_case_id | param 1 |
        | trash        | value 1 |
    """
    And the following feature file "file2.feature":
    """
    Feature: Just another feature to make sure that the entire suite is checked

      @test_case_5
      Scenario:
        * a step
    """
    When the existing ids are determined
    Then the following ids are found:
      | 1   |
      | 5   |
      | 7   |
      | 7-1 |
      | 7-2 |
      | 8-1 |


  Scenario: No existing tags
    Given the following feature file:
    """
    Feature:

      Scenario:
        * a step
    """
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """

  Scenario: Existing tags
    Given the following feature file:
    """
    Feature:

      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step
    """
    And the following feature file:
    """
    Feature: Another file to test that the entire suite is checked

      @test_case_5
      Scenario:
        * a step
    """
    When the file is processed
    Then the resulting file "1" is:
    """
    Feature:

      @test_case_6
      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step
    """
    And the resulting file "2" is:
    """
    Feature: Another file to test that the entire suite is checked

      @test_case_5
      Scenario:
        * a step
    """

  Scenario: Explicit starting index

  Note: By explicitly setting the starting index, there is no guarantee that the indexes used will not conflict with
  existing indexes.

    Given the following feature file:
    """
    Feature:

      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step

      Scenario:
        * a step
    """
    And a start index of "1"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step

      @test_case_2
      Scenario:
        * a step
    """


  Scenario: Outline, no existing sub-ids
    Given the following feature file:
    """
    Feature:

      Scenario Outline:
        * a <param>
      Examples:
        | param |
        | value |
    """
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a <param>
      Examples:
        | param | test_case_id |
        | value | 1-1          |
    """

  Scenario: Outline, existing sub-ids

  Note: Existing sub ids count against the indexes available for their associated parent id. If ids are mismatched (see
  the feature on test case id validation), indexes are still assigned appropriately to avoid duplication.

    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-1          |
        | value2 |              |
      Examples:
        | param  | test_case_id |
        | value1 | 1-3          |
        | value2 |              |

      Scenario Outline:
        * a <param>
      Examples: with a sub-id not associated with the parent test case
        | param  | test_case_id |
        | value1 | 8-1          |
        | value2 |              |

      @test_case_8
      Scenario Outline: the outline that sub-id 8-1 should count against
        * a <param>
      Examples:
        | param  | test_case_id |
        | value2 |              |
    """
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-1          |
        | value2 | 1-4          |
      Examples:
        | param  | test_case_id |
        | value1 | 1-3          |
        | value2 | 1-5          |

      @test_case_9
      Scenario Outline:
        * a <param>
      Examples: with a sub-id not associated with the parent test case
        | param  | test_case_id |
        | value1 | 8-1          |
        | value2 | 9-1          |

      @test_case_8
      Scenario Outline: the outline that sub-id 8-1 should count against
        * a <param>
      Examples:
        | param  | test_case_id |
        | value2 | 8-2          |
    """

  Scenario: Outline, explicit starting index

  Note: Explicit starting indexes for sub-ids can be declared even if the parent id does not exist yet.

  Note: By explicitly setting the starting index, there is no guarantee that the indexes used will not conflict with
  existing indexes.

    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-2          |
        | value2 |              |
        | value3 |              |

      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 2-1          |
        | value2 |              |
        | value3 |              |
    """
    And a start index of "2"
    And a start index of "1" for testcase "1"
    And a start index of "1" for testcase "2"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-2          |
        | value2 | 1-1          |
        | value3 | 1-2          |

      @test_case_2
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 2-1          |
        | value2 | 2-1          |
        | value3 | 2-2          |
    """

  Scenario: Default indexing still applies to non-explicit indexes
    Given the following feature file:
    """
    Feature:

      Scenario Outline: Letting the default set the primary index
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-2          |
        | value2 | 3-2          |
        | value3 |              |

      @test_case_2
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 2-1          |
        | value2 |              |
        | value3 |              |
    """
    And a start index of "1" for testcase "2"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_3
      Scenario Outline: Letting the default set the primary index
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 1-2          |
        | value2 | 3-2          |
        | value3 | 3-3          |

      @test_case_2
      Scenario Outline:
        * a <param>
      Examples:
        | param  | test_case_id |
        | value1 | 2-1          |
        | value2 | 2-1          |
        | value3 | 2-2          |
    """

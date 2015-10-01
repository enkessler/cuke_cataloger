Feature: Tagging test cases for uniqueness

  Tests are tagged based on a simple <prefix><unique_id> pattern. Every test gets a tag at the test level and, in the case outlines, a sub-id for each of its example rows. Any test which has already been given an id tag or other id information will not have that information modified by the tagging process.


  Background:
    * a tag prefix of "@test_case_"


  Scenario: Tagging tests that don't have id tags

  This is one of the most common cases, wherein new tests have been written but they have not yet been tagged by the tagging tool.

    Given the following feature file:
      """
      Feature:

        Scenario:
          * a step

        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 |
          | value 1 |
        Examples: without rows
          | param 1 |
      """
    When the file is processed
    Then the resulting file is:
      """
      Feature:

        @test_case_1
        Scenario:
          * a step

        @test_case_2
        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 | test_case_id |
          | value 1 | 2-1          |
        Examples: without rows
          | param 1 | test_case_id |
      """

  Scenario: Tagging tests that already have id tags

  This is the other most common case, wherein existing tests have already been tagged by the tagging tool.

    Given the following feature file:
      """
      Feature:

        @test_case_1
        Scenario:
          * a step

        @test_case_2
        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 | test_case_id |
          | value 1 | 2-1          |
        Examples: without rows
          | param 1 | test_case_id |
      """
    When the file is processed
    Then the resulting file is:
      """
      Feature:

        @test_case_1
        Scenario:
          * a step

        @test_case_2
        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 | test_case_id |
          | value 1 | 2-1          |
        Examples: without rows
          | param 1 | test_case_id |
      """


  Scenario: Tagging outlines that are partially 'filled in'

  Whereas scenarios either have an id tag or don't, outlines have many more places for identifying information to be placed and it is quite possible that some of that information is already present. Maybe several scenarios were combined into one outline and an id tag got carried over. Maybe an extra row or entire example table was added to an already tagged outline. Maybe someone removed id information by accident. In any case, the missing information is replaced by the tagging tool.

    Given the following feature file:
      """
      Feature:

        @test_case_1
        Scenario Outline: Has an id tag, but no sub-ids
          * a step
        Examples: with rows
          | param 1 |
          | value 1 |
        Examples: without rows
          | param 1 |

        Scenario Outline: Sub-ids present but no top level tag
          * a step
        Examples: Missing row ids
          | param 1 | test_case_id |
          | value 2 |              |
          | value 1 | some_id      |
        Examples: Already has id column
          | param 1 | test_case_id |
        Examples: Doesn't have id column
          | param 1 |
          | value 3 |
      """
    When the file is processed
    Then the resulting file is:
      """
      Feature:

        @test_case_1
        Scenario Outline: Has an id tag, but no sub-ids
          * a step
        Examples: with rows
          | param 1 | test_case_id |
          | value 1 | 1-1          |
        Examples: without rows
          | param 1 | test_case_id |

        @test_case_2
        Scenario Outline: Sub-ids present but no top level tag
          * a step
        Examples: Missing row ids
          | param 1 | test_case_id |
          | value 2 | 2-1          |
          | value 1 | some_id      |
        Examples: Already has id column
          | param 1 | test_case_id |
        Examples: Doesn't have id column
          | param 1 | test_case_id |
          | value 3 | 2-2          |
      """

  Scenario: Tagging a multi-file test suite
    Given the following feature file:
      """
      Feature:

        Scenario:
          * a step
      """
    And the following feature file:
      """
      Feature:

        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 |
          | value 1 |
        Examples: without rows
          | param 1 |
        Examples: some more rows
          | param 1 |
          | value 1 |
      """
    When the files are processed
    Then the resulting first file is:
      """
      Feature:

        @test_case_1
        Scenario:
          * a step
      """
    And the resulting second file is:
      """
      Feature:

        @test_case_2
        Scenario Outline:
          * a step
        Examples: with rows
          | param 1 | test_case_id |
          | value 1 | 2-1          |
        Examples: without rows
          | param 1 | test_case_id |
        Examples: some more rows
          | param 1 | test_case_id |
          | value 1 | 2-2          |
      """

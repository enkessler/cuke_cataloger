Feature: Tagging formatting

  In an effort to have the added tag scheme be as unobtrusive as possible, tagging needs to fit in with the existing
  source code as well as possible.


  Background:
    And a tag prefix of "@test_case_"

  Scenario: Test level tags have the same indentation as the test itself
    Given the following feature file:
    """
    Feature:

    Scenario:
      * a step

      Scenario:
      * a step

        Scenario:
        * a step
    """
    When the files are processed
    Then the resulting file is:
    """
    Feature:

    @test_case_1
    Scenario:
      * a step

      @test_case_2
      Scenario:
      * a step

        @test_case_3
        Scenario:
        * a step
    """

  Scenario: The column for sub-ids is appropriately whitespace buffered
    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: column name is longer than sub-id
        | param 1 |
        | value 1 |

      @test_case_123456789101112
      Scenario Outline:
        * a step
      Examples: sub-id is longer than column name
        | param 1 |
        | value 1 |
    """
    When the files are processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: column name is longer than sub-id
        | param 1 | test_case_id |
        | value 1 | 1-1          |

      @test_case_123456789101112
      Scenario Outline:
        * a step
      Examples: sub-id is longer than column name
        | param 1 | test_case_id      |
        | value 1 | 123456789101112-1 |
    """

  Scenario: The column for sub-ids is last
    Given a feature file
    When the file is processed
    Then the column for sub-ids is placed after all other columns

  Scenario: Test tags can be added above existing tags
    Given the following feature file:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      Scenario: Test with tags

      Scenario: Test without tags
    """
    And  the tag should be at the "top"
    When the files are processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      @tag_1
      @tag_2 @tag_3

      Scenario: Test with tags

      @test_case_2
      Scenario: Test without tags
    """

  Scenario: Test tags can be added below existing tags
    Given the following feature file:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      Scenario: Test with tags

      Scenario: Test without tags
    """
    And  the tag should be at the "bottom"
    When the files are processed
    Then the resulting file is:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3
      @test_case_1

      Scenario: Test with tags

      @test_case_2
      Scenario: Test without tags
    """

  Scenario: Test tags can be added adjacent to the test
    Given the following feature file:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      Scenario: Test with tags

      Scenario: Test without tags
    """
    And  the tag should be at the "side"
    When the files are processed
    Then the resulting file is:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      @test_case_1
      Scenario: Test with tags

      @test_case_2
      Scenario: Test without tags
    """

  Scenario: Test tagging location defaults to adjacent
    Given the following feature file:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      Scenario:
    """
    And  the tag location is unspecified
    When the files are processed
    Then the resulting file is:
    """
    Feature:

      @tag_1
      @tag_2 @tag_3

      @test_case_1
      Scenario:
    """

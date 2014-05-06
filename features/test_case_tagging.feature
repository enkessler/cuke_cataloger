Feature: Tagging test cases for uniqueness


  Scenario: Untagged scenario

  Brand new test that hasn't been tagged yet.

    Given the following feature file:
    """
    Feature:

      Scenario:
        * a step
    """
    And a tag prefix of "@test_case_"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """

  Scenario: Tagged scenario

  An older tests that doesn't need a new tag.

    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """
    And a tag prefix of "@test_case_"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """

  Scenario: Untagged outline

  Brand new test that hasn't been tagged yet.

    Given the following feature file:
    """
    Feature:

      Scenario Outline:
        * a step
      Examples: with rows
        | param 1 |
        | value 1 |
      Examples: without rows
        | param 1 |
    """
    And a tag prefix of "@test_case_"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 1-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
    """

  Scenario: Tagged outline

  An older tests that doesn't need a new tag.

    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 1-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
    """
    And a tag prefix of "@test_case_"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 1-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
    """

  Scenario: Partially tagged outline, has tag

  An older test that has had new examples added to it. Possibly due to a
  conversion from a scenario to an outline.

    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: with rows
        | param 1 |
        | value 1 |
      Examples: without rows
        | param 1 |
    """
    And a tag prefix of "@test_case_"
    When the file is processed
    Then the resulting file is:
    """
    Feature:

      @test_case_1
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 1-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
    """

  Scenario: Complex example
    Given the following feature file:
    """
    Feature:

      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step

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

      @test_case_2
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 2-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
      Examples: some more rows
        | test_case_id | param 1 |
        | 2-2          | value 1 |

      @test_case_3
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 3-1          | value 1 |
      Examples: without rows
        | param 1 |
      Examples: some more rows
        | param 1 |
        | value 1 |
    """
    And the following feature file:
    """
    Feature: Just another feature to use up some tag indexes

      New indexes start after the highest found index so as not to repeat the
      indexes of older tests that might have since been removed.


      @test_case_5
      Scenario:
        * a step
    """
    And a tag prefix of "@test_case_"
    When the files are processed
    Then the resulting file "1" is:
    """
    Feature:

      @test_case_6
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
      Examples: some more rows
        | test_case_id | param 1 |
        | 7-2          | value 1 |

      @test_case_2
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 2-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
      Examples: some more rows
        | test_case_id | param 1 |
        | 2-2          | value 1 |

      @test_case_3
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 3-1          | value 1 |
      Examples: without rows
        | test_case_id | param 1 |
      Examples: some more rows
        | test_case_id | param 1 |
        | 3-2          | value 1 |
    """
    And the resulting file "2" is:
    """
    Feature: Just another feature to use up some tag indexes

      New indexes start after the highest found index so as not to repeat the
      indexes of older tests that might have since been removed.


      @test_case_5
      Scenario:
        * a step
    """

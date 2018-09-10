Feature: Checking existing tags for correctness

  Both the size of any non-trivial test suite and the potential for human error encourages
  the ability to determine that the id tags in a test suite are correct in a programmatic fashion.
  Therefore, the tool provides such a means.


  *Note*: When validating, a tag prefix of '@test_case_' and a column id of 'test_case_id' will be used unless different
  values are specified

  Scenario: Detection of missing test ids when not present
    Given the following feature file "has_untagged_tests.feature":
    """
    Feature:

      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then the following tests are found to be missing ids:
      | path/to/has_untagged_tests.feature:3 |

  Scenario: Detection of missing test ids when present
    Given the following feature file:
    """
    Feature:

      @test_case_42
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then no tests are found to be missing ids

  Scenario: Detection of missing sub-id in an outline row when present
    Given the following feature file "has_untagged_rows.feature":
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        |              | 123   |
        |  bad_id      | 456   |
    """
    When the ids in the test suite are validated
    Then the following tests rows are found to be missing sub ids:
      | path/to/has_untagged_rows.feature:8 |

  Scenario: Detection of missing sub-id in an outline row when not present
    Given the following feature file:
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 4-1          | 123   |
        | 4-2          | 456   |
    """
    When the ids in the test suite are validated
    Then no tests rows are found to be missing sub ids

  Scenario: Detection of missing sub-id parameter column in an outline example when present
    Given the following feature file "has_missing_id_param.feature":
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | param |
        | 123   |
    """
    When the ids in the test suite are validated
    Then the following tests examples are found to be missing a parameter for sub ids:
      | path/to/has_missing_id_param.feature:6 |

  Scenario: Detection of missing sub-id parameter column in an outline example when not present
    Given the following feature file:
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 4-1          | 123   |
    """
    When the ids in the test suite are validated
    Then no test examples are found to be missing id parameters

  Scenario: Detection of duplicate ids when present
    Given the following feature file "has_duplicated_tag.feature":
    """
    Feature:

      @test_case_1
      Scenario:
        * a step

      @test_case_1
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then the following tests are found to have a duplicated id:
      | path/to/has_duplicated_tag.feature:4 |
      | path/to/has_duplicated_tag.feature:8 |

  Scenario: Detection of duplicate ids when not present
    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step

      @test_case_2
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then no tests are found to have duplicated ids

  Scenario: Detection of duplicate sub-ids when present
    Given the following feature file "has_duplicated_id.feature":
    """
    Feature:

      @test_case_2
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 2-1          | 123   |
        | 2-2          | 123   |
      Examples:
        | test_case_id | param |
        | 2-1          | 123   |
        | 2-1          | 123   |
    """
    When the ids in the test suite are validated
    Then the following tests example rows are found to have duplicated sub ids:
      | path/to/has_duplicated_id.feature:8  |
      | path/to/has_duplicated_id.feature:12 |
      | path/to/has_duplicated_id.feature:13 |

  Scenario: Detection of duplicate sub-ids when not present
    Given the following feature file:
    """
    Feature:

      @test_case_2
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 2-1          | 123   |
        | 2-2          | 123   |
      Examples:
        | test_case_id | param |
        | 2-3          | 123   |
        | 2-4          | 123   |
    """
    When the ids in the test suite are validated
    Then no test example rows are found to have duplicated sub ids

  Scenario: Row sub id does not match test id when present
  Note: An empty id is not considered a mismatch with the parent id. It is counted as a missing sub-id instead.

    Given the following feature file "has_mismatched_id.feature":
    """
    Feature:

      @test_case_4
      Scenario Outline: mismatched tag
        * a step
      Examples:
        | test_case_id | param |
        | 2-1          | 123   |

      Scenario Outline: no tag and non-empty sub-id
        * a step
      Examples:
        | test_case_id | param |
        | 2-1          | 123   |

      Scenario Outline: no tag and empty sub-id
        * a step
      Examples:
        | test_case_id | param |
        |              | 123   |

      @test_case_5
      Scenario Outline: tag and empty sub-id
        * a step
      Examples:
        | test_case_id | param |
        |              | 123   |
    """
    When the ids in the test suite are validated
    Then the following tests example rows are found to have mismatched sub ids:
      | path/to/has_mismatched_id.feature:8  |
      | path/to/has_mismatched_id.feature:14 |

  Scenario: Row sub id does not match test id when not present
    Given the following feature file:
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 4-1          | 123   |
    """
    When the ids in the test suite are validated
    Then no test example rows are found to have mismatched ids

  Scenario: More than one id tag when present
    Given the following feature file "has_multiple_test_ids.feature":
    """
    Feature:

      @test_case_1
      @test_case_2
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then the following tests are found to have multiple test ids:
      | path/to/has_multiple_test_ids.feature:5 |

  Scenario: More than one id tag when not present
    Given the following feature file:
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then no tests are found to have multiple test ids

  Scenario: Sub id is malformed when present
    Given the following feature file "has_mismatched_id.feature":
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 2-1x         | 123   |
        |              |       |
        | trash        | 123   |
    """
    When the ids in the test suite are validated
    Then the following tests example rows are found to have malformed sub ids:
      | path/to/has_mismatched_id.feature:8  |
      | path/to/has_mismatched_id.feature:10 |

  Scenario: Sub id is malformed when not present
    Given the following feature file:
    """
    Feature:

      @test_case_4
      Scenario Outline:
        * a step
      Examples:
        | test_case_id | param |
        | 4-1          | 123   |
    """
    When the ids in the test suite are validated
    Then no test example rows are found to have malformed sub ids

  Scenario: Features cannot have test case id tags, present

  Id tags should only apply to a single test. Their presence at the feature level may cause them to apply to multiple
  tests.

    Given the following feature file "has_a_feature_level_test_tag.feature":
    """
    @test_case_99
    Feature:

      @test_case_1
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then the following feature is found to have a test case tag:
      | path/to/has_a_feature_level_test_tag.feature:2 |

  Scenario: Features cannot have test case id tags, not present
    Given the following feature file "has_no_feature_level_test_tag.feature":
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then no feature is found to have a test case tag

  Scenario: Detection of missing test ids when present
    Given the following feature file:
    """
    Feature:

      @test_case_42
      Scenario:
        * a step
    """
    When the ids in the test suite are validated
    Then no tests are found to be missing ids

  Scenario: Validation covers entire test suite
    Given the following feature file "has_untagged_tests.feature":
    """
    Feature:

      Scenario:
        * a step
    """
    And the following feature file "has_even_more_untagged_tests.feature":
    """
    Feature:

      Scenario Outline:
        * a step
      Examples:
        | param |
    """
    When the ids in the test suite are validated
    Then the following tests are found to be missing ids:
      | path/to/has_untagged_tests.feature:3           |
      | path/to/has_even_more_untagged_tests.feature:3 |

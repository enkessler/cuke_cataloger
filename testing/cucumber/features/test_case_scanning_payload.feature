Feature: Scan results return useful information

  Model objects are returned in the results of a scan.

  Scenario: Scanned scenario
    Given the following feature file "file1.feature":
    """
    Feature:

      @test_case_1
      Scenario:
        * a step
    """
    And a tag prefix of "@test_case_"
    When the files are scanned
    Then the payload is a model object

  Scenario: Scanned outline
    Given the following feature file "test_file.feature":
    """
    Feature:

      @test_case_7
      Scenario Outline:
        * a step
      Examples: with rows
        | test_case_id | param 1 |
        | 7-1          | value 1 |
    """
    And a tag prefix of "@test_case_"
    When the files are scanned
    Then the payload has a test and a test row

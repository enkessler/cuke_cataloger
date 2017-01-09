Feature: Cataloging executable

  Cataloging functionality can be used directly from the command line.


  Scenario: Cataloging test cases

  Note: By default, cataloging will be done in the current directory using the '@test_case_' prefix

    Given the cuke_cataloger executable is available
    And there are test cases in the "." directory that have not been cataloged with "@test_case_"
    When the following command is executed:
    """
    cuke_cataloger catalog_test_cases
    """
    Then all of the test cases in the "." directory will be cataloged with "@test_case_"

  Scenario: Specifying cataloging options
    Given the cuke_cataloger executable is available
    And there are test cases in the "tests" directory that have not been cataloged with "@foo"
    When the following command is executed:
    """
    cuke_cataloger catalog_test_cases --location <path_to>/tests --prefix @foo
    """
    Then all of the test cases in the "tests" directory will be cataloged with "@foo"

  Scenario: Validating test cases

  Note: By default, validation will be done in the current directory using the '@test_case_' prefix

    Given the cuke_cataloger executable is available
    When the following command is executed:
    """
    cuke_cataloger validate_test_cases
    """
    Then a validation report for the "." directory with prefix "@test_case_" is output to the console

  Scenario: Specifying validation options
    Given the cuke_cataloger executable is available
    When the following command is executed:
    """
    cuke_cataloger validate_test_cases --location <path_to>/tests  --prefix @foo --file <path_to>/foo.txt
    """
    Then a validation report for the "tests" directory with prefix "@foo" is output to "foo.txt"

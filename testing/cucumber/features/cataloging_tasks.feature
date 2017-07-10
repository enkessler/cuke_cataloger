Feature: Cataloging tasks

  Cataloging functionality can be invoked using Rake tasks that are provided by this gem.


  Background: Rake task availability
    * the Rake tasks provided by the gem have been loaded


  Scenario: Cataloging test cases

  Note: By default, cataloging will be done in the current directory using the '@test_case_' prefix and outline rows will also be cataloged.

    Given there are test cases in the "." directory that have not been cataloged with "@test_case_"
    When the following task is invoked:
    """
    tag_tests
    """
    Then all of the test cases in the "." directory will be cataloged with "@test_case_"

  Scenario: Specifying cataloging options

  Note: Due to the implementation of teh Rake tasks, not all options can be used from the command line. Some options only work when invoking the task within other code.

    Given there are test cases in the "tests" directory that have not been cataloged with "@foo"
    When the following code is run:
    """
    Rake::Task['tag_tests'].invoke('<path_to>/tests','@foo', false)
    """
    Then all of the scenarios and outlines in the "tests" directory will be cataloged with "@foo"
    But outline rows in the "tests" directory are not cataloged

  Scenario: Validating test cases

  Note: By default, validation will be done in the current directory using the '@test_case_' prefix

    When the following task is invoked:
    """
    validate_tests
    """
    Then a validation report for the "." directory with prefix "@test_case_" is output to the console

  Scenario: Specifying validation options
    When the following task is invoked:
    """
    validate_tests['<path_to>/tests','@foo','<path_to>/foo.txt']
    """
    Then a validation report for the "tests" directory with prefix "@foo" is output to "foo.txt"

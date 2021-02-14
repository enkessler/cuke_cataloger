Basic stuff:
[![Gem Version](https://badge.fury.io/rb/cuke_cataloger.svg)](https://rubygems.org/gems/cuke_cataloger)
[![Project License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/mit-license.php)
[![Downloads](https://img.shields.io/gem/dt/cuke_cataloger.svg)](https://rubygems.org/gems/cuke_cataloger)

User stuff:
[![Cucumber Docs](http://img.shields.io/badge/Documentation-Features-green.svg)](https://github.com/enkessler/cuke_cataloger/tree/master/testing/cucumber/features)
[![Yard Docs](http://img.shields.io/badge/Documentation-API-blue.svg)](https://www.rubydoc.info/gems/cuke_cataloger)

Developer stuff:
[![Build Status](https://travis-ci.org/enkessler/cuke_cataloger.svg?branch=master)](https://travis-ci.org/enkessler/cuke_cataloger)
[![Build status](https://ci.appveyor.com/api/projects/status/9a7gw3r5ddfugtf0/branch/master?svg=true)](https://ci.appveyor.com/project/enkessler/cuke-cataloger)
[![Coverage Status](https://coveralls.io/repos/github/enkessler/cuke_cataloger/badge.svg?branch=master)](https://coveralls.io/github/enkessler/cuke_cataloger?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/662f0e7aa69bf9725515/maintainability)](https://codeclimate.com/github/enkessler/cuke_cataloger/maintainability)
[![Inline docs](http://inch-ci.org/github/enkessler/cuke_cataloger.svg?branch=master)](https://inch-ci.org/github/enkessler/cuke_cataloger)


---


# CukeCataloger


The cuke_cataloger gem is a convenient way to provide a unique id to every test case in your Cucumber test suite.

Turn your features from this

````
Feature:

  Scenario:
    * a step
    
  Scenario Outline:
    * a step
  Examples:
    | param 1 |
    | value 1 |
  Examples: 
    | param 1 |
    | value 1 |
    | value 2 |

  Scenario:
    * a step
````

into this!

````
Feature:

  @test_case_1
  Scenario:
    * a step
    
  @test_case_2
  Scenario Outline:
    * a step
  Examples:
    | param 1 | test_case_id |
    | value 1 | 2-1          |
  Examples: 
    | param 1 | test_case_id |
    | value 1 | 2-2          |
    | value 2 | 2-3          |

  @test_case_3
  Scenario:
    * a step
````


## Installation

Add this line to your application's Gemfile:

    gem 'cuke_cataloger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cuke_cataloger

## Usage

In addition to using the provided classes in any regular Ruby script, the gem's functionality can be accessed through the command line or through the provided Rake tasks.

### Command Line

    cuke_cataloger catalog_test_cases [--location=LOCATION] [--prefix=PREFIX][--[no-]row-id] [--id-column-name=ID_COLUMN_NAME]

and

    cuke_cataloger validate_test_cases [--location=LOCATION] [--prefix=PREFIX] [--[no-]row-id] [--id-column-name=ID_COLUMN_NAME] [--file=FILE]


### Rake Task

Require the gem

    require 'cuke_cataloger'

and then call its task creation method in your Rakefile (or wherever you like to keep your Rake tasks) in order to generate the tasks.

    CukeCataloger.create_tasks

If you want the tasks to be created in a certain namespace, simply call the creation method from within that namespace.

    namespace 'foo' do
      CukeCataloger.create_tasks
    end

This will create tasks that can then be invoked in the usual manner:

    rake tag_tests['path/to/your/tests','@test_case_']

and

    rake validate_tests['path/to/your/tests','@test_case_','validation_results.txt']
  
### Adding ids to tests

The the tagging functionality will add an id tag to every scenario (and an id column to every outline) in a test suite. It can be given a directory in which the tests are located and a prefix upon which to base the tagging scheme but, if not given that information, it will use the current directory and a prefix of `@test_case_`.

    rake tag_tests['path/to/your/tests','@my_prefix_']

The above example would result in the tags `@my_prefix_1`, `@my_prefix_2`, `@my_prefix_3`, etc. being added to every test in the `tests` directory.

### Validating test ids

The the validating functionality scans a given directory for any problems related to id tags and generates a report detailing its results. It can be given a directory in which the tests are located and a prefix upon which to base the tagging scheme, as well as a file location to which it should output its report but, if not given that information, it will use the current directory and a prefix of `@test_case_` and it will output the report to the console. 

    rake validate_tests['path/to/your/tests','@my_prefix_','validation_results.txt']

The above example would result in a report called `validation_results.txt` being generated for any test in the `tests` directory that had problems related to their id (e.g. did not have an id tag, had the same id tag as another test, etc.), based up the id prefix `@my_prefix_`.


### Shallow cataloging

The cataloging and validation process can be limited to the test level instead of also checking individual rows in outlines.

`cuke_cataloger catalog_test_cases --no-row-id`

`cuke_cataloger validate_test_cases --no-row-id`

`Rake::Task['tag_tests'].invoke('./features','@test_case_', false)  # 3rd argument is the row flag`

`Rake::Task['validate_tests'].invoke('./features','@test_case_',nil, false)  # 4th argument is the row flag`


### Custom id column name

By default, the cataloging and validation process uses `test_case_id` as the column name for outline rows but an alternative name can be provided.

`cuke_cataloger catalog_test_cases --id-column-name my_special_column_id`

`cuke_cataloger validate_test_cases --id-column-name my_special_column_id`

`Rake::Task['tag_tests'].invoke('./features','@test_case_', true, 'my_special_column_id')  # 4th argument is the id column name`

`Rake::Task['validate_tests'].invoke('./features','@test_case_',nil, true, 'my_special_column_id')  # 5th argument is the id column name`

For more information and usage examples, see the documentation [here](https://github.com/enkessler/cuke_cataloger/tree/master/testing/cucumber/features).

## Development and Contributing

See [CONTRIBUTING.md](https://github.com/enkessler/cuke_cataloger/blob/master/CONTRIBUTING.md)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

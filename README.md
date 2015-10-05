# CukeCataloger


[![Gem Version](https://badge.fury.io/rb/cuke_cataloger.svg)](http://badge.fury.io/rb/cuke_cataloger)
[![Build Status](https://travis-ci.org/enkessler/cuke_cataloger.svg?branch=master)](https://travis-ci.org/enkessler/cuke_cataloger)
[![Coverage Status](https://coveralls.io/repos/enkessler/cuke_cataloger/badge.svg?branch=master&service=github)](https://coveralls.io/github/enkessler/cuke_cataloger?branch=master)
[![Code Climate](https://codeclimate.com/github/enkessler/cuke_cataloger/badges/gpa.svg)](https://codeclimate.com/github/enkessler/cuke_cataloger)
[![Project License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/enkessler/cuke_cataloger/blob/master/LICENSE.txt)


The cuke_cataloger gem is a convenient way to provide a unique id to every test case in your Cucumber test suite. 

## Installation

Add this line to your application's Gemfile:

    gem 'cuke_cataloger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cuke_cataloger

## Usage

The simplest way to use this gem is to include the Rake tasks that it provides in your project. Just require the gem

    require 'cuke_cataloger'

and then call its task creation method to generate the Rake tasks.

    CukeCataloger.create_tasks

If you want the tasks to be created in a certain namespace, simply call the creation method from within that namespace.

    namespace 'foo' do
      CukeCataloger.create_tasks
    end

The classes used to tag and validate tests could also be used directly in other scripts if you want to do something more complex than the functionality provided by the two predefined Rake tasks.
  
### Adding ids to tests

The tag_tests task will add an id tag to every scenario (and an id column to every outline) in a test suite. To do this, it needs to be provided a directory in which the tests are located and a prefix upon which to base the tagging scheme.

    rake tag_tests['path/to/your/tests','@test_case_']

The above example would result in the tags @test_case_1, @test_case_2, @test_case_3, etc. being added to every test in the given directory.

### Validating test ids

The validate_tests task scan a given directory for any problems related to id tags and generate a report detailing its results. To do this, it needs to be provided a directory in which the tests are located and a prefix upon which to base the tagging scheme. It can optionally take a file location to which it should output its report instead of printing it to the console.

    rake validate_tests['path/to/your/tests','@test_case_','validation_results.txt']

The above example would result in a report called 'validation_results.txt' being generated for any test had problems related to their id (e.g. did not have an id tag, had the same id tag as another test, etc.).

## Contributing

1. Fork it ( http://github.com/<my-github-username>/cuke_cataloger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

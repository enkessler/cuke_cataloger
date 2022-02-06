# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet...

## [2.0.0] - 2022-02-05

### Added

 - Added support for Ruby 3.x

### Removed

  - Removed support for some older versions of the gem's dependencies:
    - Ruby 1.x
    - Rake 0.x
    - CukeModeler 0.x

### Fixed

 - Test case IDs are no longer erroneously detected if a tag only partially matches the ID pattern. For example, the 
   gem would incorrectly identify `@test_case_123_plus_more` as an ID tag even though it was not one.
 - Cataloging tests now correctly handles tests that are nested in rules. Previously, the presence of a `Rule` 
   keyword would cause new ID tags to be placed on the wrong lines in the cataloged file.  


## [1.6.0] - 2020-06-21

### Added
 - Support added for more versions of the `cuke_modeler` gem
   - 3.x
   - 2.x

 - Support added for more versions of the `rake` gem
   - 13.x

 - Support added for more versions of the `thor` gem
   - 1.x

## [1.5.0] - 2018-09-09

### Added
  - The default cataloging prefix used by the Rake tasks is now also the default prefix used by the various object 
    based methods.

## [1.4.1] - 2017-07-09

### Changed
- Improved documentation

## [1.4.0] -  2017-04-18

### Added
  - Both cataloging and validation can now be used without including outline rows, if desired.
  - The column header used for outline row ids is now configurable.

## [1.3.1] - 2017-01-11

### Fixed
  - Added missing shebang line to the gem's executable file.

## [1.3.0] - 2017-01-09

### Added
  - Added an executable file for the gem so that it can be used without having to use Rake tasks.
  - A basic cataloging location and prefix is used by default so that specifying these values will not be necessary in 
    many cases.

### Fixed
  - Replaced non-Ruby 1.8.x compatible code so that the gem now correctly works with older versions of Ruby.

## [1.2.0] - 2016-10-02

### Added
  - The gem now declares version limits on all of its dependencies.
  - Added support for the 1.x series of the 'cuke_modeler' gem.

## [1.1.0] - 2016-02-21

### Added
  - Upgraded to a more recent version of the 'cuke_modeler' gem and removed monkey patches that were
    previously providing functionality that is now present in the newer version of 'cuke_modeler'

## [1.0.0] - 2015-10-05

- Initial release


[Unreleased]: https://github.com/enkessler/cuke_cataloger/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.6.0...v2.0.0
[1.6.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/enkessler/cuke_cataloger/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/enkessler/cuke_cataloger/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/enkessler/cuke_cataloger/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/enkessler/cuke_cataloger/compare/e2084caddc80886a3b6b8ff000f220e56ca92a05...v1.0.0

# Release history

### Version 1.3.1 / 2017-01-11

- Bug fix: Added missing shebang line to the gem's executable file.


### Version 1.3.0 / 2017-01-09

- Bug fix: Replaced non-Ruby 1.8.x compatible code so that the gem now correctly works with older versions of Ruby.

- Added an executable file for the gem so that it can be used without having to use Rake tasks.

- A basic cataloging location and prefix is used by default so that specifying these values will not be necessary in many cases.


### Version 1.2.0 / 2016-10-02

- The gem now declares version limits on all of its dependencies.
  
- Added support for the 1.x series of the 'cuke_modeler' gem.


### Version 1.1.0 / 2016-02-21

- Upgraded to a more recent version of the 'cuke_modeler' gem and removed monkey patches that were
  previously providing functionality that is now present in the newer version of 'cuke_modeler'


### Version 1.0.0 / 2015-10-05

- Initial release

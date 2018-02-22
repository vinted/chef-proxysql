Testing chef-proxysql
======================================

This cookbook is equipped with both unit tests (chefspec) and integration tests
(test-kitchen and serverspec). Contributions to this cookbook should include tests
for new features or bugfixes, with a preference for unit tests over integration
tests to ensure speedy testing runs. ***All tests and most other commands here
should be run using bundler*** and our standard Gemfile. This ensures that
contributions and changes are made in a standardized way against the same
versions of gems. We recommend installing rubygems-bundler so that bundler is
automatically inserting `bundle exec` in front of commands run in a directory
that contains a Gemfile.

A full test run of all tests and style checks would look like:

```bash
$ bundle exec kitchen list
$ bundle exec kitchen verify
$ bundle exec kitchen destroy
```

The final destroy is intended to clean up any systems that failed a test, and is
mostly useful when running with kitchen drivers for cloud providers, so that no
machines are left orphaned and costing you money.

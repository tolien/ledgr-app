[![Coverage Status](https://coveralls.io/repos/tolien/data-tracker/badge.png)](https://coveralls.io/r/tolien/data-tracker)

[![Dependency Status](https://gemnasium.com/tolien/data-tracker.png)](https://gemnasium.com/tolien/data-tracker)

Master branch: [![Build Status](https://travis-ci.org/tolien/data-tracker.png?branch=master)](https://travis-ci.org/tolien/data-tracker)
Rails 4 branch: [![BuildStatus](https://secure.travis-ci.org/tolien/data-tracker.png?branch=rails4)](http://travis-ci.org/tolien/data-tracker)

# data-tracker #
An open-source attempt at building something broadly similar to the self-logging site [daytum](http://daytum.com/).

To be absolutely clear, this is not intended to be a simple clone of Daytum;
the "plan" is to build around a publicly available API (something Daytum thus far lacks)
and to add features which I think would be useful.

If you're not familiar with daytum, the basic structure is:

Users have items (for example, 'Tea') which are members of categories ('Drinks') and can then make entries ('1 cup of tea at 12:15 on the 26th of July 2013').

On top of that are displays which have a type (e.g. bar chart) and which use the data for a particular category.

### Setup ###

* fork and clone this repo
* set up secret_token.rb:

* Copy secret_token.rb.sample to secret_token.rb
* Put different strings in place of 'supersekrit' ("rake secret" will generate something valid)

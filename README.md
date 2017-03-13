# Piawe

This gem implements a PIAWE report generator

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jg_piawe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem build piawe.gemspec 
    $ gem install jg_piawe-0.1.1.gem

## Usage

Once the gem has been installed, PIAWE reports can be produced using the piawe_report command line utility. The syntax for this utility is:

```
piawe_report peopleFile rulesFile [reportDate]
```
e.g.:
```
piawe_report ~/workspace/piawe/spec/files/people.json ~/workspace/piawe/spec/files/rules_fixed.json '2017/02/01'
```

The date parameter is optional - it will default to the current date if omitted.

The report will be output to stdout.

## PLEASE NOTE: The rules file provided at https://github.com/DoneSafe/code_test had some invalid overlaps - testing with that file will result in this Gem rejecting the file with a descriptive exception.

Doc and Coverage reports have been included in the repo for convenience.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/piawe/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).



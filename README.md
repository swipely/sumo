# sumo-search

[![Gem Version](https://badge.fury.io/rb/sumo-search.png)](http://badge.fury.io/rb/sumo-search) [![Build Status](https://travis-ci.org/swipely/sumo.svg?branch=add-fog-style-credential-loading)](https://travis-ci.org/swipely/sumo) [![Code Climate](https://codeclimate.com/github/swipely/sumo.png)](https://codeclimate.com/github/swipely/sumo) [![Dependency Status](https://gemnasium.com/swipely/sumo-search.svg)](https://gemnasium.com/swipely/sumo-search)

This gem interfaces with the Sumo Logic [Search Job API](https://github.com/SumoLogic/sumo-api-doc/wiki/search-job-api).
It may be used through native Ruby, or via a CLI that has been provided.

## Installation

From the command line:

```bash
$ [sudo] gem install sumo-search
```

From your application's `Gemfile`:

```ruby
gem 'sumo-search'
```

Or you can `require` it using:

```ruby
require 'sumo'
```

## Configuration

Your credentials go into the YAML file `~/.sumo_creds`.
An example YAML file is listed below:

```yaml
backend:
  email: email@test.net
  password: trustno1
default:
  email: email2@test.net
  password: test-pass
```

The credentials in the `default` namespace are loaded by default.
To change this, set `ENV['SUMO_CREDENTIAL']` to the credential that you would like to load.

## Ruby Usage

To create a search job from ruby, the `Sumo.search` method is provided.
For example, the following creates a search job for everything from the 2014-01-01:

```ruby
search = Sumo.search(
  :query => '*',
  :from => '2014-01-01T00:00:00',
  :to => '2014-01-01T23:59:59',
  :time_zone => 'UTC'
)
```

To iterate through the messages returned by the API, use the `#messages` method on the object returned by `Sumo.search`.

```ruby
search.messages.each { |message| puts message }
```

Similarly, iterating through the records can be acheived through the `#records` method.

```ruby
search.records.each { |record| puts record }
```

Note that the two above methods lazily grab the results in chunks, so iterating through these will take some time.
The difference between records and messages is described at the bottom of [this section](https://github.com/SumoLogic/sumo-api-doc/wiki/search-job-api#wiki-getting-the-current-search-job-status) of the api docs.

## CLI Usage

The executable packaged with this gem is called `sumo`.

| Option           | Required | Description                                     |
|------------------|----------|-------------------------------------------------|
| -q --query       | `true`   | The query to send to the API                    |
| -f --from        | `true`   | The start date of the query (iso8601)           |
| -t --to          | `true`   | The end date of the query (iso8601)             |
| -z --time-zone   | `true`   | The time zone of the start and end dates        |
| -e --extract-key | `false`  | Extract the given key from the returned message |
| -r --records     | `false`  | Print out the records, not messages             |
| -v --version     | `false`  | Print the version and exit                      |
| -h --help        | `false`  | Print the help message and exit.                |

Examples:

```bash
# Search for everything from 2014-01-01.
sumo --query '*' --from '2014-01-01T00:00:00' --to '2014-01-01T23:59:59' --time-zone 'UTC'

# Search for everything containing 'StagingFitness' in 2013, extracting the 'message' key from the response.
sumo --query 'StagingFitness' --from '2013-01-01T00:00:00' --to '2014-01-01T00:00:00' --time-zone 'UTC' --extract-key 'message'
```

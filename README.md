# Tr4n5l4te

**Version: 0.1.12**

Use Google Translate without an API key.

Like me, maybe you've found that Google makes it a pain to work with their API. Tr4n5l4te gets around all that.

## Installation

First, install [PhantomJS](http://phantomjs.org/).

Add this line to your application's Gemfile:

```ruby
gem 'tr4n5l4te'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tr4n5l4te

## Usage

In your code:

```ruby
translator = Tr4n5l4te::Translator.new
english_strings = [
  'hello',
  'how are you'
]
english_strings.each do |text|
  puts translator.translate(text, :en, :es)
end
# => hola
# => cómo estás
```

### Command Line

    ➤ ./exe/translate -h
    Options:
      -y, --yaml-file=<s>     A YAML locale file - filename determines source language 'en.yml' - English
      -l, --lang=<s>          Destination language
      -i, --list              List known languages
      -s, --sleep-time=<i>    Sleep time (default: 2)
      -t, --timeout=<i>       Poltergeist timeout option (default: 30)
      -v, --verbose           Be verbose with output
      -h, --help              Show this message

To translate a YAML file:

    $ ./exe/translate -y /path/to/yml/file -l "destination-language"

The translator will sleep for 2 seconds, by default, between each string translation. You can override that by passing in the amount of time, in seconds, you want it to sleep:

    $ ./exe/translate -y config/locales/en.yml -l French -s 3

Warning: If you pass in '0' and translate a large file, it is very likely that Google will ban your IP address.

To list all known languages

    $ ./exe/translate --list

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Specs

The specs are sprinkled with integration tests which will actually go out and hit the live web. To run them:

    $ INTEGRATION=1 rake spec

Please be kind or Google is likely to ban your IP address.

#### Spec Coverage

    $ INTEGRATION=1 COVERAGE=1 rake spec
    $ open coverage/index.html # if you are on OSX

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midwire/tr4n5l4te.

### Contributors

Thanks to all of those who contribute!

* @kirylpl - Fixed phantomjs selector, migration to Optimist gem

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

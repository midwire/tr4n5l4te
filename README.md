# Tr4n5l4te

**Version: 1.1.0**

Use Google Translate without an API key.

Like me, maybe you've found that Google makes it a pain to work with their API. Tr4n5l4te gets around all that by using Google's free translation endpoint directly via HTTP — no browser, no API key, no headless dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tr4n5l4te'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tr4n5l4te

Requires Ruby >= 3.2.

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

Ruby string interpolation variables (`%{var}`) are preserved through translation.

### Command Line

    ➤ ./exe/translate -h
    Options:
      -y, --yaml-file=<s>     A YAML locale file - filename determines source language 'en.yml' - English
      -l, --lang=<s>          Destination language
      -i, --list              List known languages
      -s, --sleep-time=<i>    Sleep time (default: 2)
      -t, --timeout=<i>       HTTP request timeout (default: 30)
      -p, --proxy=<s>         Proxy - host:port or user:pass@host:port
      -v, --verbose           Be verbose with output
      -h, --help              Show this message

To translate a YAML file:

    $ ./exe/translate -y /path/to/yml/file -l "destination-language"

The translator will sleep for 2 seconds, by default, between each string translation. You can override that by passing in the amount of time, in seconds, you want it to sleep:

    $ ./exe/translate -y config/locales/en.yml -l French -s 3

Warning: If you pass in '0' and translate a large file, it is very likely that Google will ban your IP address.

### Proxy Support

Route requests through an HTTP proxy to avoid IP bans or to use from behind a firewall:

    $ ./exe/translate -y config/locales/en.yml -l French -p proxy.example.com:8080

With authentication:

    $ ./exe/translate -y config/locales/en.yml -l French -p user:pass@proxy.example.com:8080

You can also configure a proxy programmatically:

```ruby
Tr4n5l4te.configure do |config|
  config.proxy = { addr: 'proxy.example.com', port: 8080 }
  # or with authentication:
  config.proxy = { addr: 'proxy.example.com', port: 8080, user: 'user', pass: 'pass' }
end
```

To list all known languages

    $ ./exe/translate --list

## Configuration

```ruby
Tr4n5l4te.configure do |config|
  config.timeout = 60 # HTTP request timeout in seconds (default: 30)
  config.proxy = { addr: 'proxy.example.com', port: 8080 } # optional HTTP proxy
end
```

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
* @gahia - Fixed phantomjs SSL handshake problem, Look for and report non-neutral gender translations. Now accepts the "male" translation by default and warns that there are alternatives, Don't fail if a translation is not found but instead show a warning message and continue.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

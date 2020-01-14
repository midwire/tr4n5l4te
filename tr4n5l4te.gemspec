# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tr4n5l4te/version'

Gem::Specification.new do |spec|
  spec.name          = 'tr4n5l4te'
  spec.version       = Tr4n5l4te::VERSION
  spec.authors       = ['Chris Blackburn']
  spec.email         = ['87a1779b@opayq.com']

  spec.summary       = 'Use Google Translate without an API key.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/midwire/tr4n5l4te'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov', '~> 0.11'

  spec.add_dependency 'capybara', '~> 2.6'
  spec.add_dependency 'colored', '~> 1'
  spec.add_dependency 'midwire_common', '~> 0.1'
  spec.add_dependency 'optimist'
  spec.add_dependency 'poltergeist', '~> 1.9'
end

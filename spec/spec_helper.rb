# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/bin'
    add_filter '/stubs'
    add_filter '/tmp'
    add_filter '/vendor'
    add_filter '/spec'

    add_group 'Modules', 'module'
    add_group 'Libraries', 'lib'
  end
end

require 'pry-nav'
require 'tr4n5l4te'

Dir[Tr4n5l4te.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.order = 'random'
  config.profile_examples = 3

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
end

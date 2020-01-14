# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

begin
  require 'midwire_common/rake_tasks'
rescue StandardError => e
  puts(">>> Can't load midwire_common/rake_tasks.")
  puts(">>> Did you 'bundle exec'?: #{e.message}")
  exit
end

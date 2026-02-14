# frozen_string_literal: true

require 'tr4n5l4te/version'

require 'midwire_common/yaml_setting'
require 'midwire_common/hash'

module Tr4n5l4te
  class << self
    attr_accessor :configuration

    def root
      Pathname.new(File.dirname(__FILE__)).parent
    end

    def string_id
      'tr4n5l4te'
    end

    def home_directory
      Dir.home
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  autoload :Configuration,  'tr4n5l4te/configuration'
  autoload :Language,       'tr4n5l4te/language'
  autoload :Runner,         'tr4n5l4te/runner'
  autoload :Translator,     'tr4n5l4te/translator'
end

Tr4n5l4te.configuration = Tr4n5l4te::Configuration.new

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

    def default_config_directory
      ".#{string_id}"
    end

    def default_cookie_filename
      'cookies.yml'
    end

    def home_directory
      ENV.fetch('HOME')
    end

    # If you don't have a HOME directory defined, you are on an OS that is
    # retarded, and this call will fail.
    def cookie_file
      dir = File.join(home_directory, default_config_directory)
      module_string = string_id.upcase
      file = ENV.fetch(
        "#{module_string}_COOKIES",
        File.join(dir, default_cookie_filename)
      )
      FileUtils.mkdir_p(dir)
      FileUtils.touch(file)
      file
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  autoload :Agent,          'tr4n5l4te/agent'
  autoload :Configuration,  'tr4n5l4te/configuration'
  autoload :Language,       'tr4n5l4te/language'
  autoload :Runner,         'tr4n5l4te/runner'
  autoload :Translator,     'tr4n5l4te/translator'
end

Tr4n5l4te.configure {}

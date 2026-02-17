# frozen_string_literal: true

require 'optimist'
require 'colored'
require 'fileutils'
require 'midwire_common/string'
require 'pry' unless ENV.fetch('GEM_ENV', nil).nil?

module Tr4n5l4te
  # rubocop:disable Metrics/ClassLength
  class Runner
    attr_accessor :logger, :options, :count

    def self.instance
      @instance ||= new
    end

    def initialize
      @options = collect_args
      validate_args
    end

    def run
      start_time = Time.now
      log_identifier(start_time)
      @count = 0

      apply_configuration

      hash = YAML.load_file(options[:yaml_file])
      translated = process(hash)
      store_translation(replace_lang_key(translated))

      puts("Processed #{@count} strings in [#{Time.now - start_time}] seconds.".yellow)
    end

    private

    def process(hash)
      hash.each_with_object({}) do |pair, h|
        key, value = pair
        h[key] = value.is_a?(Hash) ? process(value) : translate(value)
        h
      end
    end

    def translate(string)
      @count += 1
      puts("Translating [#{string}]") if options[:verbose]
      translator.translate(string, from_lang, options[:lang])
    end

    def translator
      @translator ||= Translator.new(sleep_time: options[:sleep_time])
    end

    def from_lang
      @from_lang ||= begin
        md = File.basename(options[:yaml_file]).match(/^(\w\w)\.yml$/)
        fail "Could not determine language from yaml file: '#{options[:yaml_file]}'" unless md

        md[1]
      end
    end

    def replace_lang_key(translated)
      assumed_source_lang = translated.keys.first
      return translated unless assumed_source_lang == from_lang

      { options[:lang] => translated.values.first }
    end

    def store_translation(translated)
      data = translated.to_yaml(line_width: -1)
      dir = File.dirname(options[:yaml_file])
      base = File.basename(options[:yaml_file]).gsub(/#{from_lang}\.yml$/, '')
      File.write(File.join(dir, "#{base}#{options[:lang]}.yml"), data)
    end

    # rubocop:disable Metrics/MethodLength
    def collect_args
      # rubocop:disable Metrics/BlockLength
      Optimist.options do
        # rubocop:enable Metrics/BlockLength
        opt(
          :yaml_file,
          "A YAML locale file - filename determines source language 'en.yml' - English",
          type: :string, required: false, short: 'y'
        )
        opt(
          :lang,
          'Destination language',
          type: :string, required: false, short: 'l'
        )
        opt(
          :list,
          'List known languages',
          type: :boolean, required: false
        )
        opt(
          :sleep_time,
          'Sleep time',
          type: :integer, default: 2, short: 's'
        )
        opt(
          :timeout,
          'HTTP request timeout - default 30',
          type: :integer, default: 30, short: 't'
        )
        opt(
          :proxy,
          'Proxy - host:port or user:pass@host:port',
          type: :string, required: false, short: 'p'
        )
        opt(
          :verbose,
          'Be verbose with output',
          type: :boolean, required: false, short: 'v', default: false
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def validate_args
      if options[:list]
        puts("#{'Valid languages:'.yellow}\n\n")
        puts("#{Language.list.join(', ').yellow}\n\n")
        exit
      end
      if !options[:lang_given] || !Language.valid?(options[:lang])
        puts("#{'Valid languages:'.red}\n\n")
        puts("#{Language.list.join(', ').yellow}\n\n")
        Optimist.die(:lang, "'#{options[:lang]}' language unknown".red)
      end
      if !options[:yaml_file_given] || !File.exist?(options[:yaml_file])
        puts("#{'A YAML file is required:'.red}\n\n")
        Optimist.die(:yaml_file, "'#{options[:yaml_file]}' not found".red)
      end
      options[:lang] = Language.ensure_code(options[:lang])
    end
    # rubocop:enable Metrics/AbcSize

    def apply_configuration
      Tr4n5l4te.configure do |config|
        config.timeout = options[:timeout]
        config.proxy = parse_proxy(options[:proxy]) if options[:proxy]
      end
    end

    def parse_proxy(proxy_string)
      if proxy_string.include?('@')
        auth, host_port = proxy_string.split('@', 2)
        user, pass = auth.split(':', 2)
        addr, port = host_port.split(':', 2)
        { addr:, port: port.to_i, user:, pass: }
      else
        addr, port = proxy_string.split(':', 2)
        { addr:, port: port.to_i }
      end
    end

    def log_identifier(start_time)
      timestr = start_time.strftime('%H:%M:%S.%3N')
      puts("Starting Tr4n5l4te v#{Tr4n5l4te::VERSION} @#{timestr}".green)
    end
  end
  # rubocop:enable Metrics/ClassLength
end

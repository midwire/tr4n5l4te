# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module Tr4n5l4te
  class Translator
    API_URL = 'https://translate.googleapis.com/translate_a/single'

    attr_reader :sleep_time

    def initialize(args = {})
      @sleep_time = args.fetch(:sleep_time, 2)
    end

    def translate(text, from_lang, to_lang)
      preprocessed = validate_and_encode(text)
      return '' if preprocessed == ''

      response = http_translate(preprocessed, from_lang, to_lang)
      translated = extract_translation(response)
      postprocess(translated)
    rescue Net::HTTPError, JSON::ParserError, SocketError, Errno::ECONNREFUSED, Timeout::Error => e
      puts("WARNING: Translation failed for '#{text}': #{e.message}")
      text
    end

    private

    def http_translate(text, from_lang, to_lang)
      uri = URI(API_URL)
      params = { client: 'gtx', dt: 't', sl: from_lang.to_s, tl: to_lang.to_s, q: text }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = Tr4n5l4te.configuration.timeout
      http.read_timeout = Tr4n5l4te.configuration.timeout

      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(params)

      response = http.request(request)
      sleep_default

      unless response.is_a?(Net::HTTPSuccess)
        raise Net::HTTPError.new("HTTP #{response.code}", response)
      end

      response.body
    end

    def extract_translation(body)
      parsed = JSON.parse(body)
      parsed[0].map { |segment| segment[0] }.join
    end

    def preprocess(text)
      @interpolations = text.scan(/(%{.*?})/).flatten
      @interpolations.each_with_index do |var, ndx|
        stub = "VAR#{ndx}"
        text = text.gsub(var, stub)
      end
      text
    end

    def postprocess(text)
      @interpolations.each_with_index do |interp, ndx|
        stub = /VAR#{ndx}/i
        text = text.gsub(stub, interp)
      end
      text
    end

    def validate_and_encode(text)
      return '' if text.nil?
      raise "Cannot translate a [#{text.class}]: '#{text}'" unless text.respond_to?(:gsub)

      result = text.strip
      return '' if result.empty?

      preprocess(result)
    end

    def sleep_default
      sleep(sleep_time)
    end
  end
end

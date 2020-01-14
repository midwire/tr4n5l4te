# frozen_string_literal: true

require 'capybara'
require 'capybara/poltergeist'
require 'yaml'

module Tr4n5l4te
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      js_errors: false,
      timeout: Tr4n5l4te.configuration.timeout,
      phantomjs_options: ['--load-images=no']
    )
  end
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist

  class Agent
    # rubocop:disable Metrics/LineLength
    DEFAULT_UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4'
    # rubocop:enable Metrics/LineLength

    attr_reader :browser

    def initialize(options = {})
      Capybara.ignore_hidden_elements = false
      @browser = options[:browser] || Capybara.current_session
      browser.driver.headers = { 'User-Agent' => DEFAULT_UA }
    end

    def load_cookies(cookie_file)
      return false unless cookie_hash = YAML.safe_load(
        File.read(cookie_file), permitted_classes: [Capybara::Poltergeist::Cookie]
      )

      browser.driver.clear_cookies
      cookie_hash.each do |key, cookie_obj|
        browser.driver.set_cookie(
          key,
          cookie_obj.value,
          domain: cookie_obj.domain,
          path: cookie_obj.path,
          secure: cookie_obj.secure?,
          httponly: cookie_obj.httponly?,
          expires: cookie_obj.expires
        )
      end
    end
    # rubocop:enable

    def store_cookies(cookie_file)
      FileUtils.mkdir_p(File.dirname(cookie_file))
      data = YAML.dump(browser.driver.cookies)
      File.open(cookie_file, 'w') { |f| f.write(data) }
    end

    def set_cookie(name, value, options = {})
      browser.driver.set_cookie(
        name.to_s,
        value.to_s,
        domain: options.fetch(:domain, nil),
        path: options.fetch(:path, nil),
        secure: options.fetch(:secure, false),
        httponly: options.fetch(:httponly, false),
        expires: options.fetch(:expires, time_plus_years)
      )
    end

    def cookies
      browser.driver.cookies
    end

    def visit(url)
      response = browser.visit(url)
      response.recursively_symbolize_keys!
    end

    def body
      browser.body
    end

    def elements(selector_string)
      browser.all(selector_string)
    end

    private

    def time_plus_years(years = 30)
      Time.now + days(365) * years
    end

    def days(num)
      num * 86_400
    end
  end
end

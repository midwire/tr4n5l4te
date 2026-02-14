# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Agent do
    let(:test_url) { 'http://google.com/' }
    let(:agent) { Agent.new }

    context '#new' do
      it 'defaults browser to Capybara.current_session' do
        expect(agent.browser).to eq(Capybara.current_session)
      end

      it 'accepts custom browser option' do
        mock_driver = double('driver')
        allow(mock_driver).to receive(:headers=)
        mock_browser = double('browser', driver: mock_driver)
        custom_agent = Agent.new(browser: mock_browser)
        expect(custom_agent.browser).to eq(mock_browser)
      end
    end

    context 'COOKIES' do
      context '.load_cookies' do
        let(:cookie_file) { File.join(Tr4n5l4te.root, 'spec/fixtures/google_cookies.yml') }

        it 'loads the passed cookie file' do
          allow(agent.browser.driver).to receive(:clear_cookies)
          allow(agent.browser.driver).to receive(:set_cookie)
          agent.load_cookies(cookie_file)
          expect(agent.browser.driver).to have_received(:clear_cookies)
          expect(agent.browser.driver).to have_received(:set_cookie).twice
        end

        it 'returns false for empty YAML file' do
          empty_file = File.join(Tr4n5l4te.root, 'spec/fixtures/empty_cookies.yml')
          expect(agent.load_cookies(empty_file)).to eq(false)
        end
      end

      context '.store_cookies' do
        let(:cookie_file) { '/tmp/bogus.yml' }

        before do
          # rubocop:disable Style/RescueModifier
          File.delete(cookie_file) rescue nil
          # rubocop:enable Style/RescueModifier
        end

        it 'stores the passed cookie file' do
          expect(agent.store_cookies(cookie_file)).to be_truthy
          expect(File.exist?(cookie_file)).to eq(true)
        end
      end

      context '.set_cookie' do
        it 'sets a cookie' do
          expect(agent.browser.driver).to receive(:set_cookie).with(
            'bogus', 'my-value',
            domain: nil, path: nil, secure: false, httponly: false, expires: a_kind_of(Time)
          )
          agent.set_cookie(:bogus, 'my-value')
        end
      end

      context '.cookies' do
        it 'returns current cookie hash' do
          cookie = double('cookie', value: 'my-value')
          allow(agent.browser.driver).to receive(:cookies).and_return({ 'bogus-123' => cookie })
          expect(agent.cookies['bogus-123'].value).to eq('my-value')
        end
      end
    end

    # NOTE: This test will hit a live URL - be cool!
    if ENV.fetch('INTEGRATION', false)
      context '.visit', integration: true do
        it 'returns a hash with status' do
          response = agent.visit(test_url)
          expect(response).to be_a(Hash)
          expect(response[:status]).to eq('success')
        end
      end
    end

    context '.body' do
      it 'returns the raw HTML body for the request' do
        expect(agent.body).to match(/<html.+<\/html>/im)
      end
    end

    context '.elements' do
      it 'returns a enumerator' do
        expect(agent.elements('a')).to respond_to(:each)
        expect(agent.elements('a')).to respond_to(:empty?)
        expect(agent.elements('a')).to respond_to(:first)
        expect(agent.elements('a')).to respond_to(:last)
      end
    end
  end
end

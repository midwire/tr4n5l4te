# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Agent do
    let(:test_url) { 'http://google.com/' }
    let(:agent) { Agent.new }

    context 'COOKIES' do
      context '.load_cookies' do
        let(:cookie_file) { File.join(Tr4n5l4te.root, 'spec/fixtures/google_cookies.yml') }

        it 'loads the passed cookie file' do
          agent.load_cookies(cookie_file)
          expect(agent.cookies.count > 0).to eq(true)
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
          agent.set_cookie(:bogus1, 'my-value1')
          agent.set_cookie(:bogus2, 'my-value2')
          expect(agent.store_cookies(cookie_file)).to be_truthy
          expect(File.exist?(cookie_file)).to eq(true)
        end
      end

      context '.set_cookie' do
        it 'sets a cookie' do
          agent.set_cookie(:bogus, 'my-value')
          expect(agent.cookies['bogus'].value).to eq('my-value')
        end
      end

      context '.cookies' do
        it 'returns current cookie hash' do
          agent.set_cookie('bogus-123', 'my-value')
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

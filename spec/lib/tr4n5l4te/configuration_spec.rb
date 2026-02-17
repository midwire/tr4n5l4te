# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Configuration do
    describe '#new' do
      it 'has a default timeout of 30' do
        config = described_class.new
        expect(config.timeout).to eq(30)
      end

      it 'has a default proxy of nil' do
        config = described_class.new
        expect(config.proxy).to be_nil
      end
    end

    describe '#timeout=' do
      it 'can set the value' do
        Tr4n5l4te.configure do |config|
          config.timeout = 60
        end
        expect(Tr4n5l4te.configuration.timeout).to eq(60)
      end
    end

    describe '#proxy=' do
      it 'can set the value via configure block' do
        Tr4n5l4te.configure do |config|
          config.proxy = { addr: '127.0.0.1', port: 8080 }
        end
        expect(Tr4n5l4te.configuration.proxy).to eq({ addr: '127.0.0.1', port: 8080 })
      end

      it 'supports proxy with authentication' do
        Tr4n5l4te.configure do |config|
          config.proxy = { addr: '127.0.0.1', port: 8080, user: 'foo', pass: 'bar' }
        end
        proxy = Tr4n5l4te.configuration.proxy
        expect(proxy[:user]).to eq('foo')
        expect(proxy[:pass]).to eq('bar')
      end
    end

    context 'standalone instance' do
      it 'supports timeout getter and setter' do
        config = described_class.new
        config.timeout = 45
        expect(config.timeout).to eq(45)
      end

      it 'supports proxy getter and setter' do
        config = described_class.new
        config.proxy = { addr: '10.0.0.1', port: 3128 }
        expect(config.proxy).to eq({ addr: '10.0.0.1', port: 3128 })
      end
    end
  end
end

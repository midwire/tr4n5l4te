# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Configuration do
    describe '#new' do
      it 'has a default timeout of 30' do
        config = described_class.new
        expect(config.timeout).to eq(30)
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

    context 'standalone instance' do
      it 'supports timeout getter and setter' do
        config = described_class.new
        config.timeout = 45
        expect(config.timeout).to eq(45)
      end
    end
  end
end

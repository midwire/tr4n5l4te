# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tr4n5l4te do
  describe '.root' do
    it 'returns a Pathname pointing to gem root' do
      expect(described_class.root).to be_a(Pathname)
      expect(described_class.root.join('lib/tr4n5l4te.rb')).to exist
    end
  end

  describe '.string_id' do
    it "returns 'tr4n5l4te'" do
      expect(described_class.string_id).to eq('tr4n5l4te')
    end
  end

  describe '.home_directory' do
    it "returns ENV['HOME']" do
      expect(described_class.home_directory).to eq(Dir.home)
    end
  end

  describe '.configure' do
    after { described_class.configure { |c| c.timeout = 30 } }

    it 'yields Configuration and persists changes' do
      described_class.configure do |config|
        config.timeout = 99
      end
      expect(described_class.configuration.timeout).to eq(99)
    end
  end
end

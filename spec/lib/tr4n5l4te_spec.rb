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

  describe '.default_config_directory' do
    it "returns '.tr4n5l4te'" do
      expect(described_class.default_config_directory).to eq('.tr4n5l4te')
    end
  end

  describe '.default_cookie_filename' do
    it "returns 'cookies.yml'" do
      expect(described_class.default_cookie_filename).to eq('cookies.yml')
    end
  end

  describe '.home_directory' do
    it "returns ENV['HOME']" do
      expect(described_class.home_directory).to eq(ENV.fetch('HOME'))
    end
  end

  describe '.cookie_file' do
    it 'returns a path under ~/.tr4n5l4te/' do
      expect(described_class.cookie_file).to include('.tr4n5l4te')
    end

    it 'creates the directory and file' do
      file = described_class.cookie_file
      expect(File.exist?(file)).to eq(true)
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

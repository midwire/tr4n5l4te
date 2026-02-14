# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Language do
    describe '#code' do
      it 'returns the language code for a name' do
        expect(described_class.code('English')).to eq('en')
        expect(described_class.code('Yiddish')).to eq('yi')
        expect(described_class.code('Chinese')).to eq('zh-CN')
      end
    end

    describe '#valid?' do
      it 'returns true if language is known' do
        expect(described_class.valid?('en')).to be(true)
        expect(described_class.valid?('yi')).to be(true)
        expect(described_class.valid?('zh-CN')).to be(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.valid?('l33t')).to be(false)
      end

      it 'accepts language strings' do
        expect(described_class.valid?('English')).to be(true)
      end
    end

    describe '#list' do
      it 'returns an array' do
        expect(described_class.list).to be_an(Array)
      end
    end

    describe '#code_valid?' do
      it 'returns true if language is known' do
        expect(described_class.code_valid?('en')).to be(true)
        expect(described_class.code_valid?('yi')).to be(true)
        expect(described_class.code_valid?('zh-CN')).to be(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.code_valid?('l33t')).to be(false)
      end

      it 'does not accept language strings' do
        expect(described_class.code_valid?('English')).to be(false)
      end
    end

    describe '#string_valid?' do
      it 'returns true if language is known' do
        expect(described_class.string_valid?('English')).to be(true)
        expect(described_class.string_valid?('Yiddish')).to be(true)
        expect(described_class.string_valid?('Chinese')).to be(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.string_valid?('l33t')).to be(false)
      end

      it 'does not accept language codes' do
        expect(described_class.string_valid?('en')).to be(false)
      end
    end

    describe '#ensure_code' do
      it 'returns language code for a code' do
        expect(described_class.ensure_code('en')).to eq('en')
        expect(described_class.ensure_code('yi')).to eq('yi')
      end

      it 'returns language code for a language string' do
        expect(described_class.ensure_code('English')).to eq('en')
        expect(described_class.ensure_code('Yiddish')).to eq('yi')
      end

      it 'raises RuntimeError for invalid language' do
        expect { described_class.ensure_code('l33t') }.to raise_error(RuntimeError, /Invalid language/)
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Language do
    context '#code' do
      it 'returns the language code for a name' do
        expect(described_class.code('English')).to eq('en')
        expect(described_class.code('Yiddish')).to eq('yi')
        expect(described_class.code('Chinese')).to eq('zh-CN')
      end
    end

    context '#valid?' do
      it 'returns true if language is known' do
        expect(described_class.valid?('en')).to eq(true)
        expect(described_class.valid?('yi')).to eq(true)
        expect(described_class.valid?('zh-CN')).to eq(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.valid?('l33t')).to eq(false)
      end

      it 'accepts language strings' do
        expect(described_class.valid?('English')).to eq(true)
      end
    end

    context '#list' do
      it 'returns an array' do
        expect(described_class.list).to be_an(Array)
      end
    end

    context '#code_valid?' do
      it 'returns true if language is known' do
        expect(described_class.code_valid?('en')).to eq(true)
        expect(described_class.code_valid?('yi')).to eq(true)
        expect(described_class.code_valid?('zh-CN')).to eq(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.code_valid?('l33t')).to eq(false)
      end

      it 'does not accept language strings' do
        expect(described_class.code_valid?('English')).to eq(false)
      end
    end

    context '#string_valid?' do
      it 'returns true if language is known' do
        expect(described_class.string_valid?('English')).to eq(true)
        expect(described_class.string_valid?('Yiddish')).to eq(true)
        expect(described_class.string_valid?('Chinese')).to eq(true)
      end

      it 'returns false if language is not known' do
        expect(described_class.string_valid?('l33t')).to eq(false)
      end

      it 'does not accept language codes' do
        expect(described_class.string_valid?('en')).to eq(false)
      end
    end

    context '#ensure_code' do
      it 'returns language code for a code' do
        expect(described_class.ensure_code('en')).to eq('en')
        expect(described_class.ensure_code('yi')).to eq('yi')
      end

      it 'returns language code for a language string' do
        expect(described_class.ensure_code('English')).to eq('en')
        expect(described_class.ensure_code('Yiddish')).to eq('yi')
      end
    end
  end
end

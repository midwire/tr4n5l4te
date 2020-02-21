# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Translator do
    let(:translator) { described_class.new }

    if ENV.fetch('INTEGRATION', false)
      context 'with valid text' do
        context '.translate' do
          it 'translates a string' do
            expect(translator.translate('hello', :en, :es)).to match(/hola/i)
          end

          it 'translates another string' do
            expect(translator.translate('how are you', :en, :es)).to match(/cómo estás/i)
          end

          it 'does not translate ambiguous words' do
            expect(translator.translate('Friends', :en, :es)).to match(/Friends/)
          end
        end
      end
    end

    context '#new' do
      it 'returns the proper thing' do
        expect(translator).to be_a(described_class)
      end
    end

    context '.translate' do
      context 'with invalid text' do
        before { expect(translator).to_not receive(:load_cookies) }

        it 'returns an empty string if the argument is empty' do
          expect(translator.translate('', :en, :es)).to eq('')
        end

        it 'returns an empty string if the argument is nil' do
          expect(translator.translate(nil, :en, :es)).to eq('')
        end

        it 'returns an empty string if the argument is whitespace' do
          expect(translator.translate('   ', :en, :es)).to eq('')
        end

        it 'raises an error string if the text is a boolean' do
          expect do
            expect(translator.translate(true, :en, :es)).to eq('')
          end.to raise_error(RuntimeError, /cannot translate/i)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Translator do
    let(:translator) { described_class.new }

    # Sample JSON response from Google Translate API
    let(:success_body) do
      JSON.generate([
        [['hola', 'hello', nil, nil, 10]],
        nil, 'en'
      ])
    end

    let(:mock_response) do
      response = instance_double(Net::HTTPSuccess, body: success_body)
      allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      response
    end

    before do
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
      allow(translator).to receive(:sleep)
    end

    if ENV.fetch('INTEGRATION', false)
      context 'with valid text' do
        let(:translator) { described_class.new }

        before { allow(translator).to receive(:sleep) }

        context '.translate' do
          it 'translates a string' do
            expect(translator.translate('hello', :en, :es)).to match(/hola/i)
          end

          it 'translates another string' do
            expect(translator.translate('how are you', :en, :es)).to match(/cómo estás/i)
          end

          it 'handles static numbers' do
            expect(
              translator.translate('translating a number: 250', :en, :es)
            ).to match(/250/)
          end

          # rubocop:disable Style/FormatStringToken
          it 'does not mangle interpolated text' do
            src = 'It looks like your timezone is %{zone_name}'
            result = translator.translate(src, :en, :es)
            expect(result).to include('%{zone_name}')
          end
          # rubocop:enable Style/FormatStringToken
        end
      end
    end

    context '#new' do
      it 'returns the proper thing' do
        expect(translator).to be_a(described_class)
      end

      it 'defaults sleep_time to 2' do
        expect(translator.sleep_time).to eq(2)
      end

      it 'accepts custom sleep_time' do
        custom = described_class.new(sleep_time: 5)
        expect(custom.sleep_time).to eq(5)
      end
    end

    context '.translate' do
      context 'with invalid text' do
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
            translator.translate(true, :en, :es)
          end.to raise_error(RuntimeError, /cannot translate/i)
        end
      end

      context 'with valid text' do
        it 'returns translated text' do
          expect(translator.translate('hello', 'en', 'es')).to eq('hola')
        end

        it 'makes a POST request to the Google Translate API' do
          expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
          translator.translate('hello', 'en', 'es')
        end

        # rubocop:disable Style/FormatStringToken
        it 'preserves %{var} through translation' do
          body = JSON.generate([[['hola VAR0', 'hello VAR0']]])
          response = instance_double(Net::HTTPSuccess, body: body)
          allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)

          result = translator.translate('hello %{name}', 'en', 'es')
          expect(result).to eq('hola %{name}')
        end

        it 'preserves multiple %{var} interpolations' do
          body = JSON.generate([[['hola VAR0 bienvenido a VAR1', 'hello VAR0 welcome to VAR1']]])
          response = instance_double(Net::HTTPSuccess, body: body)
          allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)

          result = translator.translate('hello %{name}, welcome to %{place}', 'en', 'es')
          expect(result).to eq('hola %{name} bienvenido a %{place}')
        end
        # rubocop:enable Style/FormatStringToken
      end

      context 'with multi-segment response' do
        it 'joins segments from long text' do
          body = JSON.generate([
            [
              ['primera parte ', 'first part '],
              ['segunda parte', 'second part']
            ]
          ])
          response = instance_double(Net::HTTPSuccess, body: body)
          allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)

          result = translator.translate('first part second part', 'en', 'es')
          expect(result).to eq('primera parte segunda parte')
        end
      end

      context 'error handling' do
        it 'returns original text on HTTP error' do
          allow_any_instance_of(Net::HTTP).to receive(:request)
            .and_raise(Net::HTTPError.new('500', nil))

          expect do
            result = translator.translate('hello', 'en', 'es')
            expect(result).to eq('hello')
          end.to output(/WARNING.*Translation failed/).to_stdout
        end

        it 'returns original text on JSON parse error' do
          bad_response = instance_double(Net::HTTPSuccess, body: 'not json')
          allow(bad_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(bad_response)

          expect do
            result = translator.translate('hello', 'en', 'es')
            expect(result).to eq('hello')
          end.to output(/WARNING.*Translation failed/).to_stdout
        end

        it 'returns original text on connection error' do
          allow_any_instance_of(Net::HTTP).to receive(:request)
            .and_raise(SocketError.new('Connection refused'))

          expect do
            result = translator.translate('hello', 'en', 'es')
            expect(result).to eq('hello')
          end.to output(/WARNING.*Translation failed/).to_stdout
        end

        it 'returns original text on non-success HTTP response' do
          bad_response = instance_double(Net::HTTPForbidden, code: '403')
          allow(bad_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(bad_response)

          expect do
            result = translator.translate('hello', 'en', 'es')
            expect(result).to eq('hello')
          end.to output(/WARNING.*Translation failed/).to_stdout
        end
      end
    end
  end
end

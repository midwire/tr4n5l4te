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

          it 'handles static numbers' do
            expect(
              translator.translate('translating a number: 250', :en, :es)
            ).to match(/^traduciendo un número: 250$/)
          end

          # rubocop:disable Style/FormatStringToken
          it 'does not mangle interpolated text within tags' do
            src = 'It looks like your timezone is <strong>%{zone_name}</strong>'
            expected = 'Parece que su zona horaria es <strong> %{zone_name} </strong>'
            expect(translator.translate(src, :en, :es)).to eq(expected)
          end

          it 'does not mangle interpolated text at the end' do
            src = 'It looks like your timezone is %{zone_name}'
            expected = 'Parece que tu zona horaria es %{zone_name}'
            expect(translator.translate(src, :en, :es)).to eq(expected)
          end
          # rubocop:enable Style/FormatStringToken
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

    context 'with mocked browser' do
      let(:mock_browser) { double('browser') }
      let(:mock_agent) { double('agent', browser: mock_browser) }

      let(:translator) do
        allow(Agent).to receive(:new).and_return(mock_agent)
        described_class.new
      end

      before do
        allow(mock_agent).to receive(:visit)
        allow(mock_agent).to receive(:load_cookies)
        allow(mock_agent).to receive(:store_cookies)
        allow(translator).to receive(:sleep)
      end

      context '#new' do
        it 'defaults sleep_time to 2' do
          expect(translator.sleep_time).to eq(2)
        end

        it 'accepts custom sleep_time' do
          custom = described_class.new(sleep_time: 5)
          expect(custom.sleep_time).to eq(5)
        end
      end

      context '.translate' do
        it 'returns translated text' do
          result_element = double('element', text: +'hola')
          allow(mock_browser).to receive(:find)
            .with('.JLqJ4b.ChMk0b > span:first-child')
            .and_return(result_element)

          expect(translator.translate('hello', 'en', 'es')).to eq('hola')
        end

        it 'visits the correct Google Translate URL' do
          result_element = double('element', text: +'hola')
          allow(mock_browser).to receive(:find).and_return(result_element)

          translator.translate('hello', 'en', 'es')
          expect(mock_agent).to have_received(:visit)
            .with('https://translate.google.com/#en/es/hello')
        end

        # rubocop:disable Style/FormatStringToken
        it 'preserves %{var} through translation' do
          result_element = double('element', text: +'hola VAR0')
          allow(mock_browser).to receive(:find).and_return(result_element)

          result = translator.translate('hello %{name}', 'en', 'es')
          expect(result).to eq('hola %{name}')
        end

        it 'preserves multiple %{var} interpolations' do
          # The greedy regex captures everything between first %{ and last } as one VAR
          result_element = double('element', text: +'hola VAR0')
          allow(mock_browser).to receive(:find).and_return(result_element)

          result = translator.translate('hello %{name}, welcome to %{place}', 'en', 'es')
          expect(result).to eq('hola %{name}, welcome to %{place}')
        end
        # rubocop:enable Style/FormatStringToken
      end

      context 'Capybara::Ambiguous rescue' do
        it 'returns original text and prints warning' do
          allow(mock_browser).to receive(:find).and_raise(Capybara::Ambiguous)
          el1 = double('el1', text: 'amigos')
          el2 = double('el2', text: 'amigas')
          allow(mock_browser).to receive(:find_all)
            .with('.JLqJ4b.ChMk0b > span:first-child')
            .and_return([el1, el2])

          expect do
            result = translator.translate('Friends', 'en', 'es')
            expect(result).to eq('Friends')
          end.to output(/WARNING.*Friends.*multiple translations/).to_stdout
        end
      end

      context 'Capybara::ElementNotFound rescue' do
        it 'returns male form for gender translations' do
          allow(mock_browser).to receive(:find).and_raise(Capybara::ElementNotFound)
          female_el = double('el_f', text: 'amiga')
          male_el = double('el_m', text: +'amigo')
          allow(mock_browser).to receive(:find_all)
            .with('.J0lOec > span:first-child')
            .and_return([female_el, male_el])

          expect do
            result = translator.translate('friend', 'en', 'es')
            expect(result).to eq('amigo')
          end.to output(/WARNING.*friend.*gender translations/).to_stdout
        end

        it 'returns nil when no translation found' do
          allow(mock_browser).to receive(:find).and_raise(Capybara::ElementNotFound)
          allow(mock_browser).to receive(:find_all)
            .with('.J0lOec > span:first-child')
            .and_return([])

          expect do
            result = translator.translate('xyzzy', 'en', 'es')
            expect(result).to be_nil
          end.to output(/WARNING.*Could not find a translation.*xyzzy/).to_stdout
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

module Tr4n5l4te
  RSpec.describe Runner do
    let(:fixture_file) { File.join(Tr4n5l4te.root, 'spec/fixtures/en.yml') }

    before do
      Runner.instance_variable_set(:@instance, nil)
    end

    context '.instance' do
      it 'returns a singleton instance' do
        stub_const('ARGV', ['-l', 'es', '-y', fixture_file])
        instance1 = Runner.instance
        instance2 = Runner.instance
        expect(instance1).to equal(instance2)
      end
    end

    context 'validate_args' do
      it 'raises SystemExit when --list flag is given' do
        stub_const('ARGV', ['--list'])
        expect { Runner.new }.to raise_error(SystemExit)
      end

      it 'raises SystemExit for invalid language' do
        stub_const('ARGV', ['-l', 'invalidlang', '-y', fixture_file])
        expect { Runner.new }.to raise_error(SystemExit)
      end

      it 'raises SystemExit when YAML file does not exist' do
        stub_const('ARGV', ['-l', 'es', '-y', '/nonexistent/file.yml'])
        expect { Runner.new }.to raise_error(SystemExit)
      end

      it 'raises SystemExit when no language specified' do
        stub_const('ARGV', ['-y', fixture_file])
        expect { Runner.new }.to raise_error(SystemExit)
      end
    end

    context 'with valid args' do
      let(:runner) do
        stub_const('ARGV', ['-l', 'es', '-y', fixture_file])
        Runner.new
      end

      it 'stores options correctly' do
        expect(runner.options[:lang]).to eq('es')
        expect(runner.options[:yaml_file]).to eq(fixture_file)
      end

      it 'converts language names to codes' do
        stub_const('ARGV', ['-l', 'Spanish', '-y', fixture_file])
        name_runner = Runner.new
        expect(name_runner.options[:lang]).to eq('es')
      end
    end

    context '#from_lang' do
      it 'extracts language code from en.yml style filename' do
        stub_const('ARGV', ['-l', 'es', '-y', fixture_file])
        runner = Runner.new
        expect(runner.send(:from_lang)).to eq('en')
      end

      it 'raises error for non-matching filenames like test_file.en.yml' do
        test_file = File.join(Tr4n5l4te.root, 'spec/fixtures/test_file.en.yml')
        stub_const('ARGV', ['-l', 'es', '-y', test_file])
        runner = Runner.new
        expect { runner.send(:from_lang) }.to raise_error(RuntimeError, /Could not determine language/)
      end
    end

    context '#replace_lang_key' do
      let(:runner) do
        stub_const('ARGV', ['-l', 'es', '-y', fixture_file])
        Runner.new
      end

      it 'replaces top-level key when it matches from_lang' do
        translated = { 'en' => { 'hello' => 'hola' } }
        result = runner.send(:replace_lang_key, translated)
        expect(result).to eq({ 'es' => { 'hello' => 'hola' } })
      end

      it 'leaves hash unchanged when key does not match' do
        translated = { 'fr' => { 'hello' => 'bonjour' } }
        result = runner.send(:replace_lang_key, translated)
        expect(result).to eq({ 'fr' => { 'hello' => 'bonjour' } })
      end
    end

    context '#process' do
      let(:runner) do
        stub_const('ARGV', ['-l', 'es', '-y', fixture_file])
        Runner.new
      end

      let(:mock_translator) { double('translator') }

      before do
        allow(mock_translator).to receive(:translate).and_return('traducido')
        runner.instance_variable_set(:@translator, mock_translator)
        runner.instance_variable_set(:@count, 0)
      end

      it 'translates leaf values' do
        result = runner.send(:process, { 'key' => 'value' })
        expect(result).to eq({ 'key' => 'traducido' })
      end

      it 'recursively handles nested hashes' do
        input = { 'top' => { 'nested' => 'value' } }
        result = runner.send(:process, input)
        expect(result).to eq({ 'top' => { 'nested' => 'traducido' } })
      end
    end

    context '#run' do
      it 'completes without error' do
        Dir.mktmpdir do |tmpdir|
          tmpfile = File.join(tmpdir, 'en.yml')
          FileUtils.cp(fixture_file, tmpfile)
          stub_const('ARGV', ['-l', 'es', '-y', tmpfile])
          runner = Runner.new

          mock_translator = double('translator')
          allow(mock_translator).to receive(:translate).and_return('traducido')
          runner.instance_variable_set(:@translator, mock_translator)

          expect { runner.run }.to output(/Processed.*strings/).to_stdout

          output_file = File.join(tmpdir, 'es.yml')
          expect(File.exist?(output_file)).to eq(true)
        end
      end
    end
  end
end

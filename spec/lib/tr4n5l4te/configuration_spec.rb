# frozen_string_literal: true

require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Configuration do
    context '#timeout=' do
      it 'can set the value' do
        Tr4n5l4te.configure do |config|
          config.timeout = 60
        end
        expect(Tr4n5l4te.configuration.timeout).to eq(60)
      end
    end
  end
end

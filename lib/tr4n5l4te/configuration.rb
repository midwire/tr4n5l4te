# frozen_string_literal: true

module Tr4n5l4te
  class Configuration
    attr_accessor :timeout

    def initialize
      @timeout = 30
    end
  end
end

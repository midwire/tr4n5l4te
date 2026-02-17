# frozen_string_literal: true

module Tr4n5l4te
  class Configuration
    attr_accessor :timeout, :proxy

    def initialize
      @timeout = 30
      @proxy = nil
    end
  end
end

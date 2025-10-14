# frozen_string_literal: true

module Support
  class Sink
    def initialize
      @messages = []
    end

    def __messages__
      @messages
    end

    def method_missing(method, *args, **kwargs, &block)
      @messages << { method:, args:, kwargs:, block: }.compact
    end
  end
end

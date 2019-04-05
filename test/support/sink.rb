# frozen_string_literal: true

module Support
  class Sink
    def initialize
      @messages = []
    end

    def __messages__
      @messages
    end

    def method_missing(m, *a, **kw, &block)
      @messages << { method: m, args: a, kwargs: kw, block: block }.compact
    end
  end
end

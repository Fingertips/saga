# frozen_string_literal: true

module Support
  module OutputHelpers
    class Collector
      attr_reader :written
      def initialize
        @written = []
      end

      def write(string, _offset = nil, _opt = nil)
        @written << string
      end
    end

    def collect_stdout
      collector = Support::OutputHelpers::Collector.new
      stdout = $stdout
      $stdout = collector
      begin
        yield
      ensure
        $stdout = stdout
      end
      collector.written.join
    end

    def collect_stderr
      collector = Support::OutputHelpers::Collector.new
      stderr = $stderr
      $stderr = collector
      begin
        yield
      ensure
        $stderr = stderr
      end
      collector.written.join
    end
  end
end

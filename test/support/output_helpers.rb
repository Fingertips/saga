# frozen_string_literal: true

module Support
  class OutputHelpers
    class Collector
      attr_reader :written
      def initialize
        @written = []
      end
    
      def write(string)
        @written << string
      end
    end
  
    def collect_stdout(&block)
      collector = Support::OutputHelpers::Collector.new
      stdout = $stdout
      $stdout = collector
      begin
        block.call
      ensure
        $stdout = stdout
      end
      collector.written.join
    end

    def collect_stderr(&block)
      collector = Support::OutputHelpers::Collector.new
      stderr = $stderr
      $stderr = collector
      begin
        block.call
      ensure
        $stderr = stderr
      end
      collector.written.join
    end
  end
end

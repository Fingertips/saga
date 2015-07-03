begin
  require 'rubygems'
rescue LoadError
end

# Mocha really wants to add MiniTest or TestUnit extensions, we don't need those
ENV['MOCHA_OPTIONS'] = 'skip_integration'

require 'bacon'
require 'mocha-on-bacon'

Bacon.extend Bacon::TapOutput
$:.unshift(File.expand_path('../../lib', __FILE__))
require 'saga'

module OutputHelper
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
    collector = Collector.new
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
    collector = Collector.new
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

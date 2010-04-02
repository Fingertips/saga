begin
  require 'rubygems'
rescue LoadError
end

module Saga
  autoload :Document,  'saga/document'
  autoload :Formatter, 'saga/formatter'
  autoload :Parser,    'saga/parser'
  autoload :Planning,  'saga/planning'
  autoload :Runner,    'saga/runner'
  autoload :Tokenizer, 'saga/tokenizer'
  
  def self.run(argv)
    runner = ::Saga::Runner.new(argv)
    runner.run
    runner
  end
end
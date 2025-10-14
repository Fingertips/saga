module Saga
  autoload :Document,  'saga/document'
  autoload :Formatter, 'saga/formatter'
  autoload :Parser,    'saga/parser'
  autoload :Planning,  'saga/planning'
  autoload :Runner,    'saga/runner'
  autoload :Tokenizer, 'saga/tokenizer'
  autoload :Verifier,  'saga/verifier'

  def self.run(argv)
    runner = ::Saga::Runner.new(argv)
    runner.run
    runner
  end
end

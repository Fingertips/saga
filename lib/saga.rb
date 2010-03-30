module Saga
  autoload :Runner, 'saga/runner'
  
  def self.run(argv)
    runner = ::Saga::Runner.new(argv)
    runner.run
    runner
  end
end
module Saga
  def self.run(argv)
    require 'saga/runner'
    
    runner = Saga::Runner.new(argv)
    runner.run
    runner
  end
end
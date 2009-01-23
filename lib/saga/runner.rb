require 'optparse'

module Saga
  class Runner
    def initialize(argv)
      @argv = argv
    end
    
    def parser
      OptionParser.new do |opts|
        opts.banner =  "Usage: saga <command> [options]"
        opts.separator ""
        opts.on("-h", "--help", "Show help") do
          puts opts
          exit
        end
      end
    end
    
    def run_command(command, options)
    end
    
    def run
      argv = @argv.dup
      if argv.empty?
        parser.parse!(argv)
        if command = argv.shift
          run_command(command, options)
        else
          puts parser.to_s
        end
      end
    end
  end
end
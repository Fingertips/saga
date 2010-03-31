require 'optparse'
 
module Saga
  class Runner
    def initialize(argv)
      @argv = argv
      @options = {}
    end
    
    def parser
      OptionParser.new do |opts|
        opts.banner =  "Usage: saga [command] [options] <file>"
        opts.separator ""
        opts.on("-h", "--help", "Show help") do
          puts opts
          exit
        end
      end
    end
    
    def run_command(command, options)
      case command
      when :run
      else
        filename = File.expand_path(command)
        document = Saga::Parser.parse(File.read(filename))
        puts Saga::Formatter.format(document)
      end
    end
    
    def run
      argv = @argv.dup
      parser.parse!(argv)
      if command = argv.shift
        run_command(command, @options)
      else
        puts parser.to_s
      end
    end
  end
end
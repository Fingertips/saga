require 'optparse'
 
module Saga
  class Runner
    def initialize(argv)
      @argv = argv
      @options = {}
    end
    
    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner =  "Usage: saga [command]"
        opts.separator ""
        opts.separator "Commands:"
        opts.separator "    new                 - prints a blank stub"
        opts.separator "    convert <filename>  - convert the stories to HTML"
        opts.separator "    inspect <filename>  - print the internals of the document"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-h", "--help", "Show help") do
          puts opts
          exit
        end
      end
    end
    
    def new_file
      document = Saga::Document.new
      document.title = '(Title)'
      document.authors << self.class.author
      Saga::Formatter.format(document, :template => 'saga')
    end
    
    def convert(filename)
      Saga::Formatter.format(Saga::Parser.parse(File.read(filename)))
    end
    
    def write_parsed_document(filename)
      document = Saga::Parser.parse(File.read(filename))
      puts document.title
      document.authors.each { |author| p author }
      puts
      document.stories.each { |header, stories| puts header; stories.each { |story| p story } }
      puts
      document.definitions.each { |header, definitions| puts header; definitions.each { |definition| p definition } }
    end
    
    def autofill(filename)
      document = Saga::Parser.parse(File.read(filename))
      document.autofill_ids
      Saga::Formatter.format(document, :template => 'saga')
    end
    
    
    def run_command(command, options)
      case command
      when 'new'
        puts new_file
      when 'convert'
        puts convert(File.expand_path(@argv[1]))
      when 'inspect'
        write_parsed_document(File.expand_path(@argv[1]))
      when 'autofill'
        puts autofill(File.expand_path(@argv[1]))
      else
        puts convert(File.expand_path(command))
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
    
    def self.author
      name = `osascript -e "long user name of (system info)" &1> /dev/null`.strip
      {:name => name}
    end
  end
end
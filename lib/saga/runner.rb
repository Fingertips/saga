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
        opts.separator "    autofill <filename> - adds an id to stories without one"
        opts.separator "    planning <filename> - shows the planning of stories in iterations"
        opts.separator "    template <dir>      - creates a template directory"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-t", "--template DIR", "Use an external template for conversion to HTML") do |template_path|
          @options[:template] = File.expand_path(template_path)
        end
        opts.on("-h", "--help",     "Show help") do
          puts opts
          exit
        end
      end
    end
    
    def new_file
      document = Saga::Document.new
      document.title = 'Title'
      document.authors << self.class.author
      document.stories[''] = [{
        :description => 'As a writer I would like to write stories so developers can implement them.',
        :id => 1,
        :status => 'todo'
      }]
      document.definitions[''] = [{
        :title => 'Writer',
        :definition => 'Someone who is responsible for writing down requirements in the form of stories'
      }]
      
      Saga::Formatter.saga_format(document)
    end
    
    def convert(filename, options)
      Saga::Formatter.format(Saga::Parser.parse(File.read(filename)), options)
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
      Saga::Formatter.saga_format(document)
    end
    
    def planning(filename)
      Saga::Planning.new(Saga::Parser.parse(File.read(filename))).to_s
    end
    
    def copy_template(destination)
      if File.exist?(destination)
        puts "The directory `#{destination}' already exists!"
      else
        require 'fileutils'
        FileUtils.mkdir_p(destination)
        FileUtils.cp(File.join(Saga::Formatter.template_path, 'default/helpers.rb'), destination)
        FileUtils.cp(File.join(Saga::Formatter.template_path, 'default/document.erb'), destination)
      end
    end
    
    def run_command(command, options)
      case command
      when 'new'
        puts new_file
      when 'convert'
        puts convert(File.expand_path(@argv[0]), options)
      when 'inspect'
        write_parsed_document(File.expand_path(@argv[0]))
      when 'autofill'
        puts autofill(File.expand_path(@argv[0]))
      when 'planning'
        puts planning(File.expand_path(@argv[0]))
      when 'template'
        copy_template(File.expand_path(@argv[0]))
      else
        puts convert(File.expand_path(command), options)
      end
    end
    
    def run
      parser.parse!(@argv)
      if command = @argv.shift
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

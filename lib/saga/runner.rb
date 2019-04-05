require 'optparse'
require 'ostruct'

module Saga
  class Runner
    def initialize(argv)
      @argv = argv
    end

    def options
      unless defined?(@options)
        @options = OpenStruct.new(run: true)
        parser.parse!(@argv)
      end
      @options
    end

    def parser
      @parser ||= OptionParser.new do |parser|
        parser.banner =  'Usage: saga [command]'
        parser.separator ''
        parser.separator 'Commands:'
        parser.separator '    new                 - prints a blank stub'
        parser.separator '    convert <filename>  - convert the stories to HTML'
        parser.separator '    inspect <filename>  - print the internals of the document'
        parser.separator '    autofill <filename> - adds an id to stories without one'
        parser.separator '    planning <filename> - shows the planning of stories in iterations'
        parser.separator '    template <dir>      - creates a template directory'
        parser.separator ''
        parser.separator 'Options:'
        parser.on('-t', '--template DIR', 'Use an external template for conversion to HTML') do |template_path|
          @options.template_path = File.expand_path(template_path)
        end
        parser.on('-h', '--help', 'Show help') do
          puts parser
          @options.run = false
        end
      end
    end

    def new_file
      document = Saga::Document.new
      document.title = 'Title'
      document.authors << author
      document.stories[''] = [{
        description: 'As a writer I would like to write stories so developers can implement them.',
        id: 1,
        status: 'todo'
      }]
      document.definitions[''] = [{
        title: 'Writer',
        definition: 'Someone who is responsible for writing down requirements in the form of stories'
      }]

      Saga::Formatter.saga_format(document)
    end

    def convert_options
      {
        template_path: options.template_path
      }.compact
    end

    def convert(filename)
      Saga::Formatter.format(Saga::Parser.parse(File.read(filename)), **convert_options)
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

    def run_command(command)
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
      return unless options.run

      if command = @argv.shift
        run_command(command)
      else
        puts parser.to_s
      end
    end

    def author
      { name: `osascript -e "long user name of (system info)" &1> /dev/null`.strip }
    end
  end
end

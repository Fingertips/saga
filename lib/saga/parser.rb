module Saga
  class Parser
    attr_accessor :document

    def initialize
      @tokenizer = ::Saga::Tokenizer.new(self)
      @document  = ::Saga::Document.new
      self.current_section = :title
      @current_header = ''
    end

    def current_section=(section)
      @current_section = section
      @tokenizer.current_section = section
    end

    def parse(input)
      @tokenizer.process(input)
      @document
    end

    def handle_author(author)
      @document.authors << author
    end

    def handle_story(story)
      self.current_section = :stories
      @document.stories[@current_header] ||= []
      @document.stories[@current_header] << story
    end

    def handle_nested_story(story)
      self.current_section = :story
      parent = @document.stories[@current_header][-1]
      parent[:stories] ||= []
      parent[:stories] << story
    end

    def handle_notes(notes)
      story = @document.stories[@current_header][-1]
      if @current_section == :story
        story[:stories][-1][:notes] = notes
      else
        story[:notes] = notes
      end
    end

    def handle_definition(definition)
      self.current_section = :definitions
      @document.definitions[@current_header] ||= []
      @document.definitions[@current_header] << definition
    end

    def handle_string(string)
      return if string.strip == ''
      if string.strip == 'USER STORIES'
        self.current_section = :stories
        return @current_section
      end

      if :title == @current_section
        @document.title = string.gsub(/^requirements/i, '').strip
        self.current_section = :introduction
      elsif :introduction == @current_section
        @document.introduction << string
      else
        @current_header = string.strip
      end
    end

    def self.parse(input)
      parser = new
      parser.parse(input)
    end
  end
end
module Saga
  class Parser
    attr_accessor :document
    
    def initialize
      @tokenizer = ::Saga::Tokenizer.new(self)
      @document  = ::Saga::Document.new
      @current_section = :title
      @current_header = ''
    end
    
    def parse(input)
      @tokenizer.process(input)
      @document
    end
    
    def handle_author(author)
      @document.authors << author
    end
    
    def handle_story(story)
      @current_section = :stories
      @document.stories[@current_header] ||= []
      @document.stories[@current_header] << story
    end
    
    def handle_definition(definition)
      @current_section = :definitions
      @document.definitions[@current_header] ||= []
      @document.definitions[@current_header] << definition
    end
    
    def handle_string(string)
      return if string.strip == ''
      return(@current_section = :body) if string.strip == 'USER STORIES'
      
      if :title == @current_section
        @document.title = string.gsub(/^requirements/i, '').strip
        @current_section = :introduction
      elsif :introduction == @current_section
        @document.introduction << string
      elsif :stories == @current_section and string[0,2] == '  '
        @document.stories[@current_header][-1][:notes] = string.strip
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
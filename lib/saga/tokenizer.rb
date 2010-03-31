module Saga
  class Tokenizer
    def initialize(parser)
      @parser = parser
    end
    
    def process_line(input)
      if input[0,2].downcase == 'as'
        @parser.handle_story(self.class.tokenize_story(input))
      elsif input[0,1] == '-'
        @parser.handle_author(self.class.tokenize_author(input))
      elsif input =~ /^(\w|[-])+:/
        @parser.handle_definition(self.class.tokenize_definition(input))
      else
        @parser.handle_string(input)
      end
    end
    
    def process(input)
      input.split("\n").each do |line|
        process_line(line)
      end
    end
    
    def self.tokenize_story_attributes(input)
      return {} if input.nil?
      
      attributes = {}
      rest       = []
      parts      = input.split(/\s/)
      
      parts.each do |part|
        if part.strip == ''
          next
        elsif match = /\#(\d+)/.match(part)
          attributes[:id] = match[1].to_i
        else
          rest << part
        end
      end
      
      attributes[:status] = rest.join(' ') unless rest.empty?
      attributes
    end
    
    def self.tokenize_story(input)
      description, attributes = input.split('-')
      story = tokenize_story_attributes(attributes)
      story[:description] = description.strip
      story
    end
    
    def self.tokenize_definition(input)
      if match = /^([^:]+)\s*:\s*(.+)\s*$/.match(input)
        {:title => match[1], :definition => match[2]}
      else
        {}
      end
    end
    
    def self.tokenize_author(input)
      author = {}
      parts = input[1..-1].split(',')
      author[:name]    = parts[0].strip if parts[0]
      author[:email]   = parts[1].strip if parts[1]
      author[:company] = parts[2].strip if parts[2]
      author[:website] = parts[3].strip if parts[3]
      author
    end
  end
end
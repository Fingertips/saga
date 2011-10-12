module Saga
  class Tokenizer
    def initialize(parser)
      @parser = parser
    end
    
    def process_line(input)
      if input[0,2].downcase == 'as'
        @parser.handle_story(self.class.tokenize_story(input))
      elsif input[0,2] == '  '
        @parser.handle_notes(input.strip)
      elsif input[0,3] == '|  '
        @parser.handle_notes(input[1..-1].strip)
      elsif input[0,1] == '|'
        @parser.handle_nested_story(self.class.tokenize_story(input[1..-1]))
      elsif input[0,1] == '-'
        @parser.handle_author(self.class.tokenize_author(input))
      elsif input =~ /^\w(\w|[\s-])+:/
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
    
    def self.interval(input)
      case input.strip
      when 'd'
        :days
      when 'w'
        :weeks
      else
        :hours
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
        elsif match = /i(\d+)/.match(part)
          attributes[:iteration] = match[1].to_i
        elsif match = /(\d+)(d|w|h|)/.match(part)
          attributes[:estimate] = [match[1].to_i, interval(match[2])]
        else
          rest << part
        end
      end
      
      attributes[:status] = rest.join(' ') unless rest.empty?
      attributes
    end
    
    def self.tokenize_story(input)
      lines = input.split('\n')
      parts = input.split(' - ')
      if parts.length > 1
        story = tokenize_story_attributes(parts[-1])
        story[:description] = parts[0..-2].join('-').strip
        story
      else
        { :description => input.strip }
      end
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
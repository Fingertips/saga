module Saga
  class Tokenizer
    def initialize(parser)
      @parser = parser
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
      input
    end
  end
end
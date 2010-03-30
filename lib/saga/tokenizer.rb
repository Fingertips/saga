module Saga
  class Tokenizer
    def initialize(parser)
      @parser = parser
    end
    
    def self.tokenize_story_attributes(input)
      attributes = {}
      
      rest  = []
      parts = input.split(/\s/)
      parts.each do |part|
        if part.strip == ''
          next
        elsif match = /\#(\d+)/.match(part)
          attributes[:id] = match[1].to_i
        else
          rest << part
        end
      end
      attributes[:status] = rest.join(' ')
      
      attributes
    end
    
    def self.tokenize_story(input)
      description, attributes = input.split('-')
      story = tokenize_story_attributes(attributes)
      story[:description] = description.strip
      story
    end
  end
end
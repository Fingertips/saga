module Saga
  class Parser
    attr_accessor :stories
    
    def handle_story(attributes=nil)
      attributes   ||= {}
      self.stories ||= []
      
      attributes[:role] = attributes[:role].strip
      attributes[:task] = attributes[:task].strip
      attributes[:reason] = attributes[:reason].strip
      
      attributes[:id] = attributes[:id].to_i if attributes.has_key?(:id)
      
      self.stories << attributes
    end
  end
end
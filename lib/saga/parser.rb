module Saga
  class Parser
    attr_accessor :stories
    
    def handle_story(role, task, reason, attributes=nil)
      attributes   ||= {}
      self.stories ||= []
      
      attributes[:id] = attributes[:id].to_i if attributes.has_key?(:id)
      
      self.stories << attributes.merge(:role => role.strip, :task => task.strip, :reason => reason.strip)
    end
  end
end
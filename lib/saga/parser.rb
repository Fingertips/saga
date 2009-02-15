module Saga
  class Parser
    attr_accessor :stories
    
    def handle_story(role, task, reason)
      self.stories ||= []
      self.stories << { :role => role.strip, :task => task.strip, :reason => reason.strip }
    end
  end
end
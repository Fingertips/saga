module Saga
  class Parser
    attr_accessor :current_role, :current_task, :current_reason
    attr_accessor :stories
    
    def handle_story
      self.stories ||= []
      self.stories << { :role => current_role, :task => current_task, :reason => current_reason }
    end
  end
end
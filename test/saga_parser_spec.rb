require File.expand_path('../spec_helper', __FILE__)

describe "A Parser" do
  ROLE = 'admin'
  TASK = 'block users'
  REASON = 'I can disable their access'
  
  before do
    @parser = Saga::Parser.new
  end
  
  it "should handle stories" do
    @parser.current_role = ROLE
    @parser.current_task = TASK
    @parser.current_reason = REASON
    @parser.handle_story
    
    story = @parser.stories.last
    story[:role].should == ROLE
    story[:task].should == TASK
    story[:reason].should == REASON
  end
end
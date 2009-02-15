require File.expand_path('../spec_helper', __FILE__)

describe "A Parser" do
  ROLE = 'admin'
  TASK = 'block users'
  REASON = 'I can disable their access'
  
  before do
    @parser = Saga::Parser.new
  end
  
  it "should handle stories" do
    @parser.handle_story(ROLE, TASK, REASON)
    story = @parser.stories.last
    
    story[:role].should == ROLE
    story[:task].should == TASK
    story[:reason].should == REASON
  end
end
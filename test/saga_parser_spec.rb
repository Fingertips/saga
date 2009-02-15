require File.expand_path('../spec_helper', __FILE__)

describe "A Parser" do
  before do
    @parser = Saga::Parser.new
  end
  
  it "should handle stories" do
    @parser.handle_story(:role => ' admin ', :task => ' block users ', :reason => ' I can disable their access', :id => '12')
    story = @parser.stories.last
    
    story[:role].should == 'admin'
    story[:task].should == 'block users'
    story[:reason].should == 'I can disable their access'
    story[:id].should == 12
  end
end
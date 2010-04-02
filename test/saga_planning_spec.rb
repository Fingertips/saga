require File.expand_path('../spec_helper', __FILE__)

describe "An empty Planning" do
  before do
    @document = Saga::Document.new
    @planning = Saga::Planning.new(@document)
  end
  
  it "shows an empty planning message" do
    @planning.to_s.should == 'There are no stories yet.'
  end
end

describe "A simple Planning" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{:estimate => [12, :hours]}]
    @planning = Saga::Planning.new(@document)
  end
  
  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 12 (1 story)\n"+
      "----------------------------\n"+
      "Total         : 12 (1 story)"
  end
end

describe "A complicated Planning" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{:estimate => [12, :hours], :iteration => 1}, {:estimate => [8, :hours]}]
    @document.stories['Developer'] = [{:estimate => [1, :weeks], :iteration => 2}, {:estimate => [1, :hours], :iteration => 2}]
    @document.stories['Writer'] = [{:estimate => [5, :hours], :iteration => 1}, {:estimate => [2, :hours], :iteration => 3}]
    @planning = Saga::Planning.new(@document)
  end
  
  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 8 (1 story)\n"+
      "Iteration 1   : 17 (2 stories)\n"+
      "Iteration 2   : 41 (2 stories)\n"+
      "Iteration 3   : 2 (1 story)\n"+
      "------------------------------\n"+
      "Total         : 68 (6 stories)"
  end
end
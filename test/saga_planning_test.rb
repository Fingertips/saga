require_relative 'test_helper'

describe "An empty Planning" do
  before do
    @document = Saga::Document.new
    @planning = Saga::Planning.new(@document)
  end

  it "shows an empty planning message" do
    @planning.to_s.should == 'There are no stories yet.'
  end
end

describe "A Planning for unestimated stories" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{}, {}, {stories: [{}, {}]}]
    @planning = Saga::Planning.new(@document)
  end

  it "shows a planning" do
    @planning.to_s.should == "Unestimated   : 5 stories"
  end
end

describe "A Planning for estimated and unestimated stories" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{}, {}, {}]
    @document.stories['Member'] = [{}, {estimate: [6, :hours], stories: [{estimate: [6, :hours]}]}, {}]
    @planning = Saga::Planning.new(@document)
  end

  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 12 (2 stories)\n"+
      "------------------------------\n"+
      "Total         : 12 (2 stories)\n"+
      "\n"+
      "Unestimated   : 5 stories"
  end
end

describe "A simple Planning" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{estimate: [12, :hours]}]
    @planning = Saga::Planning.new(@document)
  end

  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 12 (one story)\n"+
      "------------------------------\n"+
      "Total         : 12 (one story)"
  end
end

describe "A complicated Planning" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{estimate: [12, :hours], iteration: 1}, {estimate: [8, :hours], stories: [{}, {}]}]
    @document.stories['Developer'] = [{estimate: [1, :weeks], iteration: 2,stories: [{estimate: [2, :hours], iteration: 2}, {estimate: [1, :hours]}]}, {estimate: [1, :hours], iteration: 2}]
    @document.stories['Writer'] = [{estimate: [5, :hours], iteration: 1}, {estimate: [2, :hours], iteration: 3}]
    @planning = Saga::Planning.new(@document)
  end

  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 9 (2 stories)\n"+
      "Iteration 1   : 17 (2 stories)\n"+
      "Iteration 2   : 43 (3 stories)\n"+
      "Iteration 3   : 2 (one story)\n"+
      "------------------------------\n"+
      "Total         : 71 (8 stories)\n"+
      "\n"+
      "Unestimated   : 2 stories"
  end
end

describe "A Planning with stories with a range estimate" do
  before do
    @document = Saga::Document.new
    @document.stories[''] = [{ estimate: ['8-40', :range] }, {}, {stories: [{ estimate: ['1d-5d', :range] }]}]
    @planning = Saga::Planning.new(@document)
  end

  it "shows a planning" do
    @planning.to_s.should ==
      "Unplanned     : 0 (2 stories)\n"+
      "-----------------------------\n"+
      "Total         : 0 (2 stories)\n"+
      "\n"+
      "Unestimated   : 2 stories\n"+
      "Range-estimate: 2 stories"
  end
end
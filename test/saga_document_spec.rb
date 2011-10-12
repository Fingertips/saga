require File.expand_path('../spec_helper', __FILE__)

describe "A Document" do
  it "responds to accessors" do
    document = Saga::Document.new
    [:title, :introduction, :authors, :stories, :definitions].each do |method|
      document.should.respond_to(method)
    end
  end
  
  it "stores stories in the order it receives them" do
    document = Saga::Document.new
    sections = %w(First Second Third Fourth Fifth)
    sections.each do |section|
      document.stories[section] = {}
    end
    document.stories.keys.should == sections
  end
  
  it "stores definitions in the order it receives them" do
    document = Saga::Document.new
    sections = %w(First Second Third Fourth Fifth)
    sections.each do |section|
      document.definitions[section] = {}
    end
    document.definitions.keys.should == sections
  end
  
  it "returns the number of stories as its length" do
    document = Saga::Document.new
    document.length == 0
    
    document.stories[''] = [{}, {}]
    document.length.should == 2
    
    document.stories['Non-functional'] = [{}]
    document.length.should == 3
  end
  
  it "know whether the document does or does not have stories" do
    document = Saga::Document.new
    document.should.be.empty
    
    document.stories[''] = [{},{}]
    document.should.not.be.empty
  end
  
  it "returns a list of used IDs" do
    document = Saga::Document.new
    document.used_ids.should == []
    
    document.stories[''] = []
    document.stories[''] << { :id => 2 }
    document.used_ids.should == [2]
    
    document.stories['Non-functional'] = []
    document.stories['Non-functional'] << { :id => 12 }
    document.used_ids.should == [2, 12]
    
    document.stories['Non-functional'] << { :id => 3 }
    document.used_ids.should == [2, 12, 3]
    
    document.stories[''][0][:stories] = [
      {}, {:id => 14}, {}, {:id => 5}
    ]
    document.used_ids.should == [2, 14, 5, 12, 3]
  end
  
  it "returns a list of unused IDs" do
    document = Saga::Document.new
    document.unused_ids(0).should == []
    document.unused_ids(3).should == [1,2,3]
    document.unused_ids(4).should == [1,2,3,4]
    
    document.stories[''] = []
    document.stories[''] << { :id => 2 }
    document.stories[''] << { :id => 4 }
    document.stories[''] << { :id => 5 }
    document.stories[''] << { :id => 6 }
    document.stories[''] << { :id => 100 }
    
    document.unused_ids(0).should == []
    document.unused_ids(1).should == [1]
    document.unused_ids(2).should == [1,3]
    document.unused_ids(3).should == [1,3,7]
    document.unused_ids(4).should == [1,3,7,8]
  end
  
  it "autofills ids" do
    document = Saga::Document.new
    document.autofill_ids
    
    document.stories[''] = []
    document.stories[''] << { :description => 'First story'}
    document.stories[''] << { :description => 'Second story', :stories => [
      { :description => 'First nested story' }, { :id => 15, :description => 'Second nested story'}
    ] }
    
    document.stories['Non-functional'] = []
    document.stories['Non-functional'] << { :id => 1, :description => 'Third story' }
    
    document.stories['Developer'] = []
    document.stories['Developer'] << { :description => 'Fourth story' }
    document.stories['Developer'] << { :id => 3, :description => 'Fifth story' }
    
    document.autofill_ids
    document.stories[''].map { |story| story[:id] }.should == [2, 4]
    document.stories[''][1][:stories].map { |story| story[:id] }.should == [5, 15]
    document.stories['Non-functional'].map { |story| story[:id] }.should == [1]
    document.stories['Developer'].map { |story| story[:id] }.should == [6, 3]
  end
end
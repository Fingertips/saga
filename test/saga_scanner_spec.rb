require File.expand_path('../spec_helper', __FILE__)

describe "Scanner" do
  STORY = "As a developer I would like to have written a site which is compliant with XHTML and CSS standards so that as many people as possible can access the site and view it as intended.\n"
  STORY_WITH_ATTRIBUTES = "As a developer I would like to have written a site which is compliant with XHTML and CSS standards so that as many people as possible can access the site and view it as intended. - #12\n"
  
  it "should have a scan methods" do
    Saga::Scanner.should.respond_to(:scan)
  end
  
  it "should raise an exception when passing a nil value for the parser" do
    lambda {
      Saga::Scanner.scan(nil, STORY)
    }.should.raise(ArgumentError)
  end
  
  it "should raise an exception when not passing a string as input" do
    lambda {
      Saga::Scanner.scan(stub, nil)
    }.should.raise(TypeError)
  end
  
  it "should scan simple stories" do
    parser = Saga::Parser.new
    Saga::Scanner.scan(parser, STORY)
    story = parser.stories.first
    
    story[:role].should == 'developer'
    story[:task].should == 'have written a site which is compliant with XHTML and CSS standards'
    story[:reason].should == 'as many people as possible can access the site and view it as intended'
  end
  
  it "should scan stories with attributes" do
    parser = Saga::Parser.new
    Saga::Scanner.scan(parser, STORY_WITH_ATTRIBUTES)
    story = parser.stories.first
    
    story[:role].should == 'developer'
    story[:task].should == 'have written a site which is compliant with XHTML and CSS standards'
    story[:reason].should == 'as many people as possible can access the site and view it as intended'
    story[:id].should == 12
  end
  
  it "should scan multiple stories" do
    parser = Saga::Parser.new
    Saga::Scanner.scan(parser, [STORY, STORY].join("\n"))
    parser.stories.length.should == 2
  end
end
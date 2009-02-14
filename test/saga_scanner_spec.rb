require File.expand_path('../spec_helper', __FILE__)

describe "Scanner" do
  STORY = "As a developer I would like to have written a site which is compliant with XHTML and CSS standards so that as many people as possible can access the site and view it as intended.\n"
  
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
    parser = stub
    parser.expects(:handle_role).with('developer')
    parser.expects(:handle_action).with('have written a site which is compliant with XHTML and CSS standards')
    parser.expects(:handle_reason).with('as many people as possible can access the site and view it as intended')
    parser.expects(:handle_story)
    
    Saga::Scanner.scan(parser, STORY)
  end
end
require File.expand_path('../spec_helper', __FILE__)

class Parser
  def self.handle_role(role)
  end
end

describe "Scanner" do
  STORY = "As an admin\n"
  
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
    parser.expects(:handle_role).with('admin')
    Saga::Scanner.scan(parser, STORY)
  end
end
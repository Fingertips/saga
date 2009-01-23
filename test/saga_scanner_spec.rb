require File.expand_path('../spec_helper', __FILE__)

describe "Scanner" do
  it "should have a scan methods" do
    Saga::Scanner.should.respond_to(:scan)
  end
  
  it "should scan simple stories" do
    parser = stub
    parser.expects(:handle_story).with('admin')
    Saga::Scanner.scan(parser, 'As an admin')
  end
end
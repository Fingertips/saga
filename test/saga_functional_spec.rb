require File.expand_path('../spec_helper', __FILE__)

describe "Saga" do
  ATTRIBUTES = [:role, :task, :reason]
  
  it "should parse requirements" do
    parser = Saga::Parser.new
    Saga::Scanner.scan(parser, File.read(File.expand_path('../cases/only_stories.saga', __FILE__)))
    
    parser.stories.length.should == 4
    parser.stories.each do |story|
      ATTRIBUTES.all? { |attribute| !story[attribute].nil? }.should == true
    end
  end
end
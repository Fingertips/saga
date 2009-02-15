require File.expand_path('../spec_helper', __FILE__)

describe "Saga" do
  STORY = "As a developer I would like to have written a site which is compliant with XHTML and CSS standards so that as many people as possible can access the site and view it as intended.\n"
  
  it "should parse requirements" do
    parser = Saga::Parser.new
    Saga::Scanner.scan(parser, STORY)
    parser.stories.length.should == 1
  end
end
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
end
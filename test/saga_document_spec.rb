require File.expand_path('../spec_helper', __FILE__)

describe "A Document" do
  it "responds to accessors" do
    document = Saga::Document.new
    [:title, :introduction, :authors, :stories, :definitions].each do |method|
      document.should.respond_to(method)
    end
  end
end
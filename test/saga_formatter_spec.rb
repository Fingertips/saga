require File.expand_path('../spec_helper', __FILE__)

describe "Formatter" do
  before do
    @document = Saga::Document.new
    @document.title = 'Requirements API'
  end
  
  it "formats a saga document to HTML" do
    html = Saga::Formatter.format(@document)
    html.should.include('<h1>Requirements <br />Requirements API</h1>')
  end
  
  it "formats a saga document to saga" do
    saga = Saga::Formatter.format(@document, :template => 'saga')
    saga.should.include('Requirements Requirements API')
  end
end
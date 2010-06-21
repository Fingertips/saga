require File.expand_path('../spec_helper', __FILE__)

describe "Formatter" do
  before do
    @document = Saga::Document.new
    @document.title = 'Requirements API'
    @document.authors = [
      {:name => 'Thijs van der Vossen', :email => 'thijs@fngtps.com', :company => 'Fingertips', :website => 'http://www.fngtps.com'},
      {:name => 'Manfred Stienstra', :email => 'manfred@fngtps.com', :company => 'Fingertips', :website => 'http://www.fngtps.com'}
    ]
    @document.introduction = [
      'A web service for interfacing with the service.', 'Exposes a public API to the application.'
    ]
    @document.stories = [
      ['General', [
        {:description => 'As a consumer I would like to use TLS (SSL) so that my connection with the API is secure', :id => 4, :status => 'todo' }
      ]]
    ]
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
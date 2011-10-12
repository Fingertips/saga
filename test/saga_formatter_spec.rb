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
        {:description => 'As a consumer I would like to use TLS (SSL) so that my connection with the API is secure', :id => 4, :status => 'todo', :notes => 'Use a self-signed CA certificate to create the certificates.', :stories => [
            { :description => 'As a consumer I would like to receive a certificate from the provider.', :id => 12, :status => 'done', :notes => 'The certificate for the CA.' },
            { :description => 'As a consumer I would like to receive a hosts file from the provider.', :id => 13, :status => 'done' }
          ]
        },
        { :description => 'As a consumer I would like to get a list of users', :id => 5, :status => 'todo' }
      ]]
    ]
  end
  
  it "formats a saga document to HTML" do
    html = Saga::Formatter.format(@document)
    html.should.include('<h1>Requirements <br />Requirements API</h1>')
    html.should.include('receive a certificate')
  end
  
  it "formats a saga document to saga" do
    saga = Saga::Formatter.saga_format(@document)
    saga.should.include('Requirements Requirements API')
    saga.should.include('receive a certificate')
  end

  describe "with an external template" do
    it "raises when the document.erb file doesn't exist" do
      lambda {
        Saga::Formatter.format(@document, :template => '/does/not/exist')
      }.should.raise(ArgumentError, "The template at path `/does/not/exist/document.erb' could not be found.")
    end

    it "omits the helpers.rb file when it doesn't exist" do
      formatter = Saga::Formatter.new(@document, :template => File.expand_path('../fixtures', __FILE__))
      formatter.expects(:load).never
      formatter.format.should.not.be.empty
    end
  end
end

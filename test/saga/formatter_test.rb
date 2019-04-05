require_relative '../test_helper'

class FormatterTest < ActiveSupport::TestCase
  setup do
    @document = create_document
  end

  test "formats a saga document to HTML" do
    html = Saga::Formatter.format(@document)
    assert html.include?('<h1>Requirements<br>Requirements API</h1>')
    assert html.include?('receive a certificate')
    assert html.include?('<td class="meta estimate">4-8</td>')
  end

  test "include the escaped introduction in the HTML output" do
    html = Saga::Formatter.format(@document)
    assert html.include?('<p>Uses &lt;20&gt; levels of redirection.</p>')
    assert html.include?('receive a certificate')
  end

  test "formats a saga document to saga" do
    saga = Saga::Formatter.saga_format(@document)
    assert saga.include?('Requirements Requirements API')
    assert saga.include?('receive a certificate')
  end

  test "raises when the document.erb file doesn't exist" do
    assert_raises(
      ArgumentError,
      "The template at path `/does/not/exist/document.erb' could not be found."
    ) do
      Saga::Formatter.format(@document, template_path: '/does/not/exist')
    end
  end

  test "omits the helpers.rb file when it doesn't exist" do
    formatter = Saga::Formatter.new(
      @document, template_path: fixture_path
    )
    assert_not_empty formatter.format
  end

  def create_document
    document = Saga::Document.new
    document.title = 'Requirements API'
    document.authors = [
      {name: 'Thijs van der Vossen', email: 'thijs@fngtps.com', company: 'Fingertips', website: 'http://www.fngtps.com'},
      {name: 'Manfred Stienstra', email: 'manfred@fngtps.com', company: 'Fingertips', website: 'http://www.fngtps.com'}
    ]
    document.introduction = [
      'A web service for interfacing with the service.', 'Exposes a public API to the application.', 'Uses <20> levels of redirection.'
    ]
    document.stories = [
      ['General', [
        {description: 'As a consumer I would like to use TLS (SSL) so that my connection with the API is secure.', id: 4, status: 'todo', notes: 'Use a self-signed CA certificate to create the certificates.', stories: [
            { description: 'As a consumer I would like to receive a certificate from the provider.', id: 12, status: 'done', notes: 'The certificate for the CA.' },
            { description: 'As a consumer I would like to receive a hosts file from the provider.', id: 13, status: 'done' }
          ]
        },
        { description: 'As a consumer I would like to get a list of users', id: 5, status: 'todo' },
        { description: 'As a consumer I would like to get details for a user', id: 5, status: 'todo', estimate: ['4-8', :range] }
      ]]
    ]
    document
  end
end

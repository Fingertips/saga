# frozen_string_literal: true

require_relative 'test_helper'

class SagaTest < ActiveSupport::TestCase
  setup do
    @document = Saga::Document.new
    @document.title = 'Requirements API'
    @document.authors = [
      {name: 'Thijs van der Vossen', email: 'thijs@fngtps.com', company: 'Fingertips', website: 'http://www.fngtps.com'},
      {name: 'Manfred Stienstra', email: 'manfred@fngtps.com', company: 'Fingertips', website: 'http://www.fngtps.com'}
    ]
    @document.introduction = [
      'A web service for interfacing with the service.', 'Exposes a public API to the application.'
    ]
    @document.stories = ActiveSupport::OrderedHash.new
    [
      ['General', [
        {description: 'As a consumer I would like to use TLS (SSL) so that my connection with the API is secure.', id: 4, status: 'todo', notes: 'Use a self-signed CA certificate to create the certificates.' }
      ]]
    ].each do |key, stories|
      @document.stories[key] = stories
    end
  end

  test "round-trips through the parser and formatter" do
    document = @document
    2.times do
      saga = Saga::Formatter.saga_format(document)
      document = Saga::Parser.parse(saga)
    end

    assert_equal @document.title, document.title
    assert_equal @document.authors, document.authors
    assert_equal @document.stories, document.stories
  end
end

module RequirementsHelper
  def files
    Dir.glob(File.expand_path("../cases/**/*.txt", __FILE__))
  end

  def requirements
    files.map do |filename|
      contents = File.read(filename)
      if contents.start_with?('Requirements')
        contents
      end
    end.compact
  end
end

class SagaRegressionTest < ActiveSupport::TestCase
  include RequirementsHelper

  test "round-trips all cases through the parser and formatter" do
    requirements.each do |contents|
      document = Saga::Parser.parse(contents)
      saga = Saga::Formatter.saga_format(document)
      assert saga.start_with?('Requirements')
    end
  end
end
require File.expand_path('../spec_helper', __FILE__)
 
require 'saga/tokenizer'

describe "Tokenizer" do
  it "tokenizes a story line" do
    line = 'As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity. - #4 todo'
    Saga::Tokenizer.tokenize_story(line).should == {
      :description => 'As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity.',
      :id => 4,
      :status => 'todo'
    }
  end
end

describe "A Tokenizer" do
  before do
    @parser    = stub('Parser')
    @tokenizer = Saga::Tokenizer.new(@parser)
  end
end
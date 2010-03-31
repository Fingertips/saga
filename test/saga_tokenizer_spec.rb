require File.expand_path('../spec_helper', __FILE__)
 
require 'saga/tokenizer'

module CasesHelper
  def _parse_expected(line)
    eval(line[3..-1])
  end
  
  def each_case(path)
    filename = File.expand_path("../cases/#{path}.txt", __FILE__)
    input = nil
    File.readlines(filename).each do |line|
      if input.nil?
        input = line.strip
      else
        yield input, _parse_expected(line)
        input = nil
      end
    end
  end
end

describe "Tokenizer" do
  extend CasesHelper
  
  it "tokenizes story attributes input" do
    each_case('story_attributes') do |input, expected|
      Saga::Tokenizer.tokenize_story_attributes(input).should == expected
    end
  end
  
  it "tokenizes story input" do
    each_case('story') do |input, expected|
      Saga::Tokenizer.tokenize_story(input).should == expected
    end
  end
  
  it "tokenizes definition input" do
    each_case('definition') do |input, expected|
      Saga::Tokenizer.tokenize_definition(input).should == expected
    end
  end
  
  it "tokenizes author input" do
    each_case('author') do |input, expected|
      Saga::Tokenizer.tokenize_author(input).should == expected
    end
  end
end

describe "A Tokenizer" do
  before do
    @parser    = stub('Parser')
    @tokenizer = Saga::Tokenizer.new(@parser)
  end
  
  it "sends a tokenized story to the parser" do
    line = 'As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity. - #4 todo'
    story = Saga::Tokenizer.tokenize_story(line)
    
    @parser.expects(:handle_story).with(story)
    @tokenizer.process_line(line)
  end
  
  it "sends a tokenized author to the parser" do
    line = '- Manfred Stienstra, manfred@fngtps.com'
    author = Saga::Tokenizer.tokenize_author(line)
    
    @parser.expects(:handle_author).with(author)
    @tokenizer.process_line(line)
  end
  
  it "sends a tokenized definition to the parser" do
    line = 'Author: Someone who writes'
    definition = Saga::Tokenizer.tokenize_definition(line)
    
    @parser.expects(:handle_definition).with(definition)
    @tokenizer.process_line(line)
  end
  
  it "forwards plain strings to the parser" do
    [
      'Requirements User Application',
      'USER STORIES',
      ''
    ].each do |line|
      @parser.expects(:handle_string).with(line)
      @tokenizer.process_line(line)
    end
  end
end
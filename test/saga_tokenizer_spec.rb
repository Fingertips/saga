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
end
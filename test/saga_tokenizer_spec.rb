require File.expand_path('../spec_helper', __FILE__)
 
module CasesHelper
  def _parse_expected(line)
    eval(line[3..-1])
  end
  
  def each_case(path)
    filename = File.expand_path("../cases/#{path}.txt", __FILE__)
    input = ''
    File.readlines(filename).each do |line|
      if line.start_with?('=>')
        yield input, _parse_expected(line)
        input = ''
      else
        input << "#{line}\n"
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
  
  it "tokenizes wild story input" do
    tokenized = Saga::Tokenizer.tokenize_story('I want to have a library of PDF document within the app. - 20 i1')
    tokenized[:description].should == "I want to have a library of PDF document within the app."
    tokenized[:iteration].should == 1
    tokenized[:estimate].should == [20, :hours]
  end
  
  it "tokenizes estimate ranges" do
    tokenized = Saga::Tokenizer.tokenize_story('I want to have a library of PDF document within the app. - i1 8-40')
    tokenized[:description].should == "I want to have a library of PDF document within the app."
    tokenized[:iteration].should == 1
    tokenized[:estimate].should == ['8-40', :range]
  end
  
  it "tokenizes hard stories" do
    Saga::Tokenizer.tokenize_story('As a member I would like the app to keep the information it got from Twitter up-to-date so that changes I make on Twitter get propagated to my listing.').should == {
      :description => 'As a member I would like the app to keep the information it got from Twitter up-to-date so that changes I make on Twitter get propagated to my listing.'
    }
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
    @tokenizer.current_section = :stories
    
    line = 'As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity. - #4 todo'
    story = Saga::Tokenizer.tokenize_story(line)
    
    @parser.expects(:handle_story).with(story)
    @tokenizer.process_line(line)
  end
  
  it "sends a tokenized note to the parser" do
    line = '  Optionally support SSL'
    notes = line.strip
    
    @parser.expects(:handle_notes).with(notes)
    @tokenizer.process_line(line)
  end
  
  it "doesn't mistake a story note with a semicolon as a definition" do
    line = '  It would be nice if we could use http://www.braintreepaymentsolutions.com/'
    @parser.expects(:handle_notes).with(line.strip)
    @tokenizer.process_line(line)
  end
  
  it "sends a nested tokenized story to the parser" do
    line = '| As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity. - #4 todo'
    story = Saga::Tokenizer.tokenize_story(line[1..-1])
    
    @parser.expects(:handle_nested_story).with(story)
    @tokenizer.process_line(line)
  end
  
  it "sends a nested tokenized note to the parser" do
    line = '|   Optionally support SSL'
    notes = line[4..-1]
    
    @parser.expects(:handle_notes).with(notes)
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
  
  it "send a tokenize defintion to the parser (slighly more complex)" do
    line = 'Search and retrieval: Stories related to selecting and retrieving recordings.'
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
  
  it "processes lines from the input" do
    input = File.read(File.expand_path("../cases/story.txt", __FILE__))
    count = input.split("\n").length
    @tokenizer.expects(:process_line).times(count)
    @tokenizer.process(input)
  end
end
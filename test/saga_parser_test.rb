require File.expand_path('../spec_helper', __FILE__)

module ParserHelper
  def parser
    @parser ||= Saga::Parser.new
  end
  
  def parse(input)
    Saga::Parser.parse(input)
  end
  
  def parse_title
    parser.parse("Requirements API\n\n")
  end
  
  def parse_introduction
    parser.parse("This document describes our API.\n\n")
  end
  
  def parse_story_marker
    parser.parse('USER STORIES')
  end
  
  def parse_header
    parser.parse('Storage')
  end
  
  def parse_story
    parser.parse('As a recorder I would like to add a recording so that it becomes available. - #1 todo')
  end
  
  def parse_wild_story
    parser.parse('In fence changing, I want the barn to progress to the next fence automatically.')
  end
  
  def parse_story_notes
    parser.parse('  “Your recording was created successfully.”')
  end
  
  def parse_nested_story
    parser.parse('| As a recorder I would like to add a recording so that it becomes available. - todo')
  end
  
  def parse_nested_story_notes
    parser.parse('|   “Your recording was created successfully.”')
  end
  
  def parse_definition
    parser.parse('Other: Stories that don’t fit anywhere else.')
  end

  def parse_unicode_definition
    parser.parse('Privé: Stories that don’t fit anywhere else.')
  end
end

describe "Parser" do
  it "should initialize and parse" do
    document = Saga::Parser.parse('')
    document.should.be.kind_of?(Saga::Document)
  end
  
  it "should initialize and parse a reference document" do
    document = Saga::Parser.parse(File.read(File.expand_path('../cases/document.txt', __FILE__)))
    document.should.be.kind_of?(Saga::Document)
    document.length.should == 3
  end
end

describe "A Parser, concerning the handling of input" do
  extend ParserHelper
  before { @parser = nil }
  
  it "interprets the first line of the document as a title" do
    document = parse('Requirements API')
    document.title.should == 'API'
    
    document = parse('Record and Search')
    document.title.should == 'Record and Search'
  end
  
  it "interprets authors" do
    document = parse('- Manfred Stienstra')
    document.authors.map { |author| author[:name] }.should == ['Manfred Stienstra']
  end
  
  it "interprets the introduction" do
    parse_title
    parse_introduction
    parser.document.introduction.should == ['This document describes our API.']
  end
  
  it "interprets stories without a header as being a gobal story" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_story
    
    parser.document.stories.keys.should == ['']
    parser.document.stories[''].length.should == 1
    parser.document.stories[''].first[:id].should == 1
  end
  
  it "parses wild stories" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_wild_story
    
    parser.document.stories.keys.should == ['']
    parser.document.stories[''].length.should == 1
    
    story = parser.document.stories[''].first
    story[:description].should == "In fence changing, I want the barn to progress to the next fence automatically."
  end
  
  it "interprets stories with a header as being part of that section" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_header
    parse_story
    
    parser.document.stories.keys.should == ['Storage']
    parser.document.stories['Storage'].length.should == 1
    parser.document.stories['Storage'].first[:id].should == 1
  end
  
  it "interprets a comment after a story as being part of the story" do
    parse_story_marker
    parse_story
    parse_story_notes
    
    parser.document.stories.keys.should == ['']
    parser.document.stories[''].length.should == 1
    parser.document.stories[''].first[:id].should == 1
    parser.document.stories[''].first[:notes].should == '“Your recording was created successfully.”'
  end
  
  it "interprets nested story as part of the parent story" do
    parse_story_marker
    parse_story
    parse_story_notes
    parse_nested_story
    parse_nested_story_notes
    parse_nested_story
    parse_nested_story_notes
    
    parser.document.stories.keys.should == ['']
    parser.document.stories[''].length.should == 1
    first_story = parser.document.stories[''][0]
    first_story[:id].should == 1
    first_story[:notes].should == '“Your recording was created successfully.”'
    
    first_story[:stories].length.should == 2
    first_story[:stories][0][:notes].should == '“Your recording was created successfully.”'
    first_story[:stories][1][:notes].should == '“Your recording was created successfully.”'
  end
  
  it "interprets definitions without a header as being a gobal definition" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_definition
    
    parser.document.definitions.keys.should == ['']
    parser.document.definitions[''].length.should == 1
    parser.document.definitions[''].first[:title].should == 'Other'
  end
  
  it "interprets definitions with a header as being part of that section" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_header
    parse_definition
    
    parser.document.definitions.keys.should == ['Storage']
    parser.document.definitions['Storage'].length.should == 1
    parser.document.definitions['Storage'].first[:title].should == 'Other'
  end
  
  it "properly parses hard cases" do
    parse_story_marker
    parser.parse('As a member I would like the app to keep the information it got from Twitter up-to-date so that changes I make on Twitter get propagated to my listing.')
    
    story = parser.document.stories[''].first
    story[:description].should == 'As a member I would like the app to keep the information it got from Twitter up-to-date so that changes I make on Twitter get propagated to my listing.'
  end
  
  it "properly parses definitions with Unicode" do
    parse_title
    parse_introduction
    parse_story_marker
    parse_unicode_definition
    
    parser.document.definitions.keys.should == ['']
    parser.document.definitions[''].length.should == 1
    parser.document.definitions[''].first[:title].should == 'Privé'
  end
end
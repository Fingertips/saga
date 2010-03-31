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
  
  def parse_definition
    parser.parse('Other: Stories that don’t fit anywhere else.')
  end
end

describe "Parser" do
  it "should initialize and parse" do
    document = Saga::Parser.parse('')
    document.should.be.kind_of?(Saga::Document)
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
end
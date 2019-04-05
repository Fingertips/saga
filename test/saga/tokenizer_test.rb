# frozen_string_literal: true

require_relative '../test_helper'

class TokenizerTest < ActiveSupport::TestCase
  def _parse_expected(line)
    eval(line[3..-1])
  end

  test "tokenizes story attributes input" do
    each_case('story_attributes') do |input, expected|
      assert_equal expected, Saga::Tokenizer.tokenize_story_attributes(input)
    end
  end

  test "tokenizes story input" do
    each_case('story') do |input, expected|
      assert_equal expected, Saga::Tokenizer.tokenize_story(input)
    end
  end

  test "tokenizes wild story input" do
    tokenized = Saga::Tokenizer.tokenize_story('I want to have a library of PDF document within the app. - 20 i1')
    assert_equal "I want to have a library of PDF document within the app.", tokenized[:description]
    assert_equal 1, tokenized[:iteration]
    assert_equal [20, :hours], tokenized[:estimate]
  end

  test "tokenizes estimate ranges" do
    tokenized = Saga::Tokenizer.tokenize_story('I want to have a library of PDF document within the app. - i1 8-40')
    assert_equal "I want to have a library of PDF document within the app.", tokenized[:description]
    assert_equal 1, tokenized[:iteration]
    assert_equal ['8-40', :range], tokenized[:estimate]
  end

  test "tokenizes hard stories" do
    assert_equal(
      {
        description: 'As a member I would like the app to keep the information it got from ' \
                     'Twitter up-to-date so that changes I make on Twitter get propagated to ' \
                     'my listing.'
      },
      Saga::Tokenizer.tokenize_story(
        'As a member I would like the app to keep the information it got from ' \
        'Twitter up-to-date so that changes I make on Twitter get propagated to ' \
        'my listing.'
      )
    )
  end

  test "tokenizes definition input" do
    each_case('definition') do |input, expected|
      assert_equal expected, Saga::Tokenizer.tokenize_definition(input)
    end
  end

  test "tokenizes author input" do
    each_case('author') do |input, expected|
      assert_equal expected, Saga::Tokenizer.tokenize_author(input)
    end
  end
end

class TokenizerBehaviorTest < ActiveSupport::TestCase
  setup do
    @parser = Support::Sink.new
    @tokenizer = Saga::Tokenizer.new(@parser)
  end

  test "sends a tokenized story to the parser" do
    @tokenizer.current_section = :stories

    line = 'As a recorder I would like to use TLS (SSL) so that my connection with the storage ' \
           'API is secure and I can be sure of the API’s identity. - #4 todo'
    story = Saga::Tokenizer.tokenize_story(line)

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_story, last_message[:method]
    assert_equal story, last_message[:kwargs]
  end

  test "sends a tokenized note to the parser" do
    line = '  Optionally support SSL'
    notes = line.strip

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_notes, last_message[:method]
    assert_equal [notes], last_message[:args]
  end

  test "doesn't mistake a story note with a semicolon as a definition" do
    line = '  It would be nice if we could use http://www.braintreepaymentsolutions.com/'
    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_notes, last_message[:method]
    assert_equal [line.strip], last_message[:args]
  end

  test "sends a nested tokenized story to the parser" do
    line = '| As a recorder I would like to use TLS (SSL) so that my connection with the storage API is secure and I can be sure of the API’s identity. - #4 todo'
    story = Saga::Tokenizer.tokenize_story(line[1..-1])

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_nested_story, last_message[:method]
    assert_equal story, last_message[:kwargs]
  end

  test "sends a nested tokenized note to the parser" do
    line = '|   Optionally support SSL'
    notes = line[4..-1]

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_notes, last_message[:method]
    assert_equal [notes], last_message[:args]
  end

  test "sends a tokenized author to the parser" do
    line = '- Manfred Stienstra, manfred@fngtps.com'
    author = Saga::Tokenizer.tokenize_author(line)

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_author, last_message[:method]
    assert_equal author, last_message[:kwargs]
  end

  test "sends a tokenized definition to the parser" do
    line = 'Author: Someone who writes'
    definition = Saga::Tokenizer.tokenize_definition(line)

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_definition, last_message[:method]
    assert_equal definition, last_message[:kwargs]
  end

  test "send a tokenize defintion to the parser (slighly more complex)" do
    line = 'Search and retrieval: Stories related to selecting and retrieving recordings.'
    definition = Saga::Tokenizer.tokenize_definition(line)

    @tokenizer.process_line(line)

    last_message = @parser.__messages__.last
    assert_equal :handle_definition, last_message[:method]
    assert_equal definition, last_message[:kwargs]
  end

  test "forwards plain strings to the parser" do
    [
      'Requirements User Application',
      'USER STORIES',
      ''
    ].each do |line|
      @tokenizer.process_line(line)

      last_message = @parser.__messages__.last
      assert_equal :handle_string, last_message[:method]
      assert_equal [line], last_message[:args]
    end
  end

  test "shows the offending line when processing a line fails" do
    parser = shape()
    tokenizer = Saga::Tokenizer.new(parser)

    line = 'The offending line'
    output = collect_stderr do
      assert_raises(NoMethodError) do
        tokenizer.process_line(line, 2)
      end
    end
    assert output.start_with?('On line 2: "The offending line":')
  end

  test "processes lines from the input" do
    input = case_contents('story')
    count = input.split("\n").length
    @tokenizer.process(input)
    assert_equal count, @parser.__messages__.length
  end
end
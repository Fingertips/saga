# frozen_string_literal: true

require_relative '../test_helper'

class ParserTest < ActiveSupport::TestCase
  test 'should initialize and parse' do
    document = Saga::Parser.parse('')
    assert_kind_of Saga::Document, document
  end

  test 'should initialize and parse a reference document' do
    document = Saga::Parser.parse(case_contents('document'))
    assert_kind_of Saga::Document, document
    assert_equal 3, document.length
  end

  include Support::ParserHelpers

  setup do
    @parser = nil
  end

  test 'interprets the first line of the document as a title' do
    document = parse('Requirements API')
    assert_equal 'API', document.title

    document = parse('Record and Search')
    assert_equal 'Record and Search', document.title
  end

  test 'interprets authors' do
    document = parse('- Manfred Stienstra')
    assert_equal ['Manfred Stienstra'], document.authors.map { |author| author[:name] }
  end

  test 'interprets the introduction' do
    parse_title
    parse_introduction
    assert_equal ['This document describes our API.'], parser.document.introduction
  end

  test 'interprets stories without a header as being a gobal story' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_story

    assert_equal [''], parser.document.stories.keys
    assert_equal 1, parser.document.stories[''].length
    assert_equal 1, parser.document.stories[''].first[:id]
  end

  test 'parses wild stories' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_wild_story

    assert_equal [''], parser.document.stories.keys
    assert_equal 1, parser.document.stories[''].length

    story = parser.document.stories[''].first
    assert_equal(
      'In fence changing, I want the barn to progress to the next fence automatically.',
      story[:description]
    )
  end

  test 'interprets stories with a header as being part of that section' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_header
    parse_story

    assert_equal ['Storage'], parser.document.stories.keys
    assert_equal 1, parser.document.stories['Storage'].length
    assert_equal 1, parser.document.stories['Storage'].first[:id]
  end

  test 'interprets a comment after a story as being part of the story' do
    parse_story_marker
    parse_story
    parse_story_notes

    assert_equal [''], parser.document.stories.keys
    assert_equal 1, parser.document.stories[''].length
    assert_equal 1, parser.document.stories[''].first[:id]
    assert_equal(
      '“Your recording was created successfully.”',
      parser.document.stories[''].first[:notes]
    )
  end

  test 'interprets nested story as part of the parent story' do
    parse_story_marker
    parse_story
    parse_story_notes
    parse_nested_story
    parse_nested_story_notes
    parse_nested_story
    parse_nested_story_notes

    assert_equal [''], parser.document.stories.keys
    assert_equal 1, parser.document.stories[''].length
    first_story = parser.document.stories[''][0]

    assert_equal 1, first_story[:id]
    assert_equal(
      '“Your recording was created successfully.”',
      first_story[:notes]
    )

    assert_equal 2, first_story[:stories].length
    assert_equal(
      '“Your recording was created successfully.”',
      first_story[:stories][0][:notes]
    )
    assert_equal(
      '“Your recording was created successfully.”',
      first_story[:stories][1][:notes]
    )
  end

  test 'interprets definitions without a header as being a gobal definition' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_definition

    assert_equal [''], parser.document.definitions.keys
    assert_equal 1, parser.document.definitions[''].length
    assert_equal 'Other', parser.document.definitions[''].first[:title]
  end

  test 'interprets definitions with a header as being part of that section' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_header
    parse_definition

    assert_equal ['Storage'], parser.document.definitions.keys
    assert_equal 1, parser.document.definitions['Storage'].length
    assert_equal 'Other', parser.document.definitions['Storage'].first[:title]
  end

  test 'properly parses hard cases' do
    parse_story_marker
    parser.parse('As a member I would like the app to keep the information it got from Twitter up-to-date so that changes I make on Twitter get propagated to my listing.')

    story = parser.document.stories[''].first
    assert_equal(
      'As a member I would like the app to keep the information it got from Twitter up-to-date ' \
      'so that changes I make on Twitter get propagated to my listing.',
      story[:description]
    )
  end

  test 'properly parses definitions with Unicode' do
    parse_title
    parse_introduction
    parse_story_marker
    parse_unicode_definition

    assert_equal [''], parser.document.definitions.keys
    assert_equal 1, parser.document.definitions[''].length
    assert_equal 'Privé', parser.document.definitions[''].first[:title]
  end
end

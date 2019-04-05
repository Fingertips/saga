# frozen_string_literal: true

module Support
  module ParserHelpers
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
end

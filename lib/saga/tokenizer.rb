module Saga
  class Tokenizer
    attr_accessor :current_section

    RE_STORY = /\./.freeze
    RE_DEFINITION = /\A[[:alpha:]]([[:alpha:]]|[\s-])+:/.freeze

    def initialize(parser)
      @parser = parser
      @current_section = nil
    end

    def expect_stories?
      %w[story stories].include?(current_section.to_s)
    end

    def process_line(input, index = 0)
      if input[0, 2] == '  '
        @parser.handle_notes(input.strip)
      elsif input[0, 3] == '|  '
        @parser.handle_notes(input[1..-1].strip)
      elsif input[0, 1] == '|'
        @parser.handle_nested_story(self.class.tokenize_story(input[1..-1]))
      elsif input[0, 1] == '-'
        @parser.handle_author(self.class.tokenize_author(input))
      elsif input =~ RE_DEFINITION
        @parser.handle_definition(self.class.tokenize_definition(input))
      elsif expect_stories? && input =~ RE_STORY
        @parser.handle_story(self.class.tokenize_story(input))
      else
        @parser.handle_string(input)
      end
    rescue StandardError
      $stderr.write "On line #{index}: #{input.inspect}:"
      raise
    end

    def process(input)
      input.split("\n").each_with_index do |line, index|
        process_line(line, index)
      end
    end

    def self.interval(input)
      case input.strip
      when 'd'
        :days
      when 'w'
        :weeks
      else
        :hours
      end
    end

    RE_STORY_NUMBER = /\#(\d+)/.freeze
    RE_STORY_ITERATION = /i(\d+)/.freeze
    RE_STORY_ESTIMATE_PART = /(\d+)(d|w|h|)/.freeze

    def self.tokenize_story_attributes(input)
      return {} if input.nil?

      attributes = {}
      rest       = []
      parts      = input.split(/\s/)

      parts.each do |part|
        if part.strip == ''
          next
        elsif match = RE_STORY_NUMBER.match(part)
          attributes[:id] = match[1].to_i
        elsif match = RE_STORY_ITERATION.match(part)
          attributes[:iteration] = match[1].to_i
        elsif match = /#{RE_STORY_ESTIMATE_PART}-#{RE_STORY_ESTIMATE_PART}/.match(part)
          estimate = "#{match[1, 2].join}-#{match[3, 2].join}"
          attributes[:estimate] = [estimate, :range]
        elsif match = RE_STORY_ESTIMATE_PART.match(part)
          attributes[:estimate] = [match[1].to_i, interval(match[2])]
        else
          rest << part
        end
      end

      attributes[:status] = rest.join(' ') unless rest.empty?
      attributes
    end

    def self.tokenize_story(input)
      parts = input.split(' - ')
      if parts.length > 1
        story = tokenize_story_attributes(parts[-1])
        story[:description] = parts[0..-2].join('-').strip
        story
      else
        { description: input.strip }
      end
    end

    def self.tokenize_definition(input)
      if match = /^([^:]+)\s*:\s*(.+)\s*$/.match(input)
        { title: match[1], definition: match[2] }
      else
        {}
      end
    end

    def self.tokenize_author(input)
      author = {}
      parts = input[1..-1].split(',')
      author[:name]    = parts[0].strip if parts[0]
      author[:email]   = parts[1].strip if parts[1]
      author[:company] = parts[2].strip if parts[2]
      author[:website] = parts[3].strip if parts[3]
      author
    end
  end
end

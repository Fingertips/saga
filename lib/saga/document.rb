module Saga
  class Document
    attr_accessor :title, :introduction, :authors, :stories, :definitions

    def initialize
      @title        = ''
      @introduction = []
      @authors      = []
      @stories      = {}
      @definitions  = {}
    end

    def copy_story(story)
      copied = {}
      %i[id iteration status estimate description].each do |attribute|
        copied[attribute] = story[attribute] if story[attribute]
      end; copied
    end

    def flatten_stories(stories)
      stories_as_flat_list = []
      stories.flatten.each do |story|
        if story[:stories]
          stories_as_flat_list << copy_story(story)
          stories_as_flat_list.concat(story[:stories])
        else
          stories_as_flat_list << story
        end
      end; stories_as_flat_list
    end

    def stories_as_flat_list
      flatten_stories(stories.values)
    end

    def _binding
      binding
    end

    def used_ids
      @stories.values.each_with_object([]) do |stories, ids|
        stories.each do |story|
          ids << story[:id]
          next unless story[:stories]

          story[:stories].each do |nested|
            ids << nested[:id]
          end
        end
      end.compact
    end

    def unused_ids(limit)
      position = 1
      used_ids = used_ids()
      (1..limit).map do
        while used_ids.include?(position) do position += 1 end
        used_ids << position
        position
      end
    end

    def length
      stories_as_flat_list.length
    end

    def empty?
      length == 0
    end

    def _autofill_ids(stories, unused_ids)
      stories.each do |story|
        story[:id] ||= unused_ids.shift
        _autofill_ids(story[:stories], unused_ids) if story[:stories]
      end
    end

    def autofill_ids
      unused_ids = unused_ids(length - used_ids.length)
      stories.each do |_section, data|
        _autofill_ids(data, unused_ids)
      end
    end
  end
end

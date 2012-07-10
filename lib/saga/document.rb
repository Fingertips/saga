require 'active_support/ordered_hash'

module Saga
  class Document
    attr_accessor :title, :introduction, :authors, :stories, :definitions
    
    def initialize
      @title        = ''
      @introduction = []
      @authors      = []
      @stories      = ActiveSupport::OrderedHash.new
      @definitions  = ActiveSupport::OrderedHash.new
    end
    
    def stories_as_flat_list
      stories_as_flat_list = []
      stories.values.flatten.each do |story|
        stories_as_flat_list << story
        stories_as_flat_list.concat(story[:stories]) if story[:stories]
      end; stories_as_flat_list
    end
    
    def _binding
      binding
    end
    
    def used_ids
      @stories.values.inject([]) do |ids, stories|
        stories.each do |story|
          ids << story[:id]
          story[:stories].each do |nested|
            ids << nested[:id]
          end if story[:stories]
        end; ids
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
    
    def autofill_ids
      unused_ids = unused_ids(length - used_ids.length)
      stories_as_flat_list.each do |story|
        story[:id] ||= unused_ids.shift
      end
    end
  end
end
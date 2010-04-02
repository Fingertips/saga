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
    
    def used_ids
      @stories.values.inject([]) do |ids, stories|
        ids.concat stories.map { |story| story[:id] }
        ids
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
      stories.inject(0) { |total, (_, stories)| total + stories.length }
    end
    
    def autofill_ids
      unused_ids = unused_ids(length - used_ids.length)
      stories.each do |_, stories|
        stories.each do |story|
          story[:id] ||= unused_ids.shift
        end
      end
    end
  end
end
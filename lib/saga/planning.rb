module Saga
  class Planning
    BLANK_ITERATION = {:story_count => 0, :estimate_total_in_hours => 0}
    
    def initialize(document)
      @document = document
    end
    
    def iterations
      @document.stories.values.flatten.inject({}) do |properties, story|
        if story[:estimate]
          iteration = story[:iteration] || -1
          properties[iteration] ||= BLANK_ITERATION.dup
          properties[iteration][:story_count] += 1
          properties[iteration][:estimate_total_in_hours] += self.class.estimate_to_hours(story[:estimate])
        end
        properties
      end
    end
    
    def total
      total = BLANK_ITERATION.dup
      iterations.each do |iteration, properties|
        total[:story_count] += properties[:story_count]
        total[:estimate_total_in_hours] += properties[:estimate_total_in_hours]
      end
      total
    end
    
    def unestimated
      unestimated = 0
      @document.stories.values.each do |stories|
        stories.each do |story|
          unestimated += 1 unless story[:estimate]
        end
      end
      unestimated
    end
    
    def statusses
      statusses = {}
      @document.stories.values.each do |stories|
        stories.each do |story|
          if story[:estimate] and story[:status]
            statusses[story[:status]] ||= 0
            statusses[story[:status]] += self.class.estimate_to_hours(story[:estimate])
          end
        end
      end
      statusses
    end
    
    def to_s
      if @document.empty?
        "There are no stories yet."
      else
        parts = iterations.keys.sort.map do |iteration|
          self.class.format_properties(iteration, iterations[iteration])
        end
        unless parts.empty?
          formatted_totals = self.class.format_properties(false, total)
          parts << '-'*formatted_totals.length
          parts << formatted_totals
        end
        if unestimated > 0 or !statusses.empty?
          parts << ''
          parts << self.class.format_unestimated(unestimated) if unestimated > 0
          parts << self.class.format_statusses(statusses) unless statusses.empty?
        end
        parts.shift if parts[0] == ''
        parts.join("\n")
      end
    end
    
    FIRST_COLUMN_WIDTH = 14
    
    def self.estimate_to_hours(estimate)
      case estimate[1]
      when :days
        estimate[0] * 8
      when :weeks
        estimate[0] * 40
      else
        estimate[0]
      end
    end
    
    def self.format_properties(iteration, properties)
      if iteration
        label = (iteration == -1) ? "Unplanned" : "Iteration #{iteration}"
      else
        label = 'Total'
      end
      story_column = (properties[:story_count] == 1) ? "#{properties[:story_count]} story" : "#{properties[:story_count]} stories"
      "#{label.ljust(FIRST_COLUMN_WIDTH)}: #{properties[:estimate_total_in_hours]} (#{story_column})"
    end
    
    def self.format_unestimated(unestimated)
      "Unestimated   : #{unestimated > 1 ? "#{unestimated} stories" : 'one story' }"
    end
    
    def self.format_statusses(statusses)
      parts = []
      statusses.each do |status, hours|
        parts << "#{status.capitalize.ljust(FIRST_COLUMN_WIDTH)}: #{hours}"
      end
      parts.join("\n")
    end
  end
end
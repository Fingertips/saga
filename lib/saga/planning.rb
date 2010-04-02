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
    
    def to_s
      if @document.empty?
        "There are no stories yet."
      else
        parts = iterations.keys.sort.map do |iteration|
          self.class.format_properties(iteration, iterations[iteration])
        end
        formatted_totals = self.class.format_properties(false, total)
        parts << '-'*formatted_totals.length
        parts << formatted_totals
        parts.join("\n")
      end
    end
    
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
      "#{label.ljust(14)}: #{properties[:estimate_total_in_hours]} (#{story_column})"
    end
  end
end
module Saga
  class Planning
    BLANK_ITERATION = {story_count: 0, estimate_total_in_hours: 0}

    def initialize(document)
      unless document
        raise ArgumentError, "Please supply a document for planning."
      end
      @document = document
    end

    def iterations
      @document.stories_as_flat_list.inject({}) do |properties, story|
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
      @document.stories_as_flat_list.each do |story|
        unestimated += 1 unless story[:estimate]
      end
      unestimated
    end

    def range_estimated
      range_estimated = 0
      @document.stories_as_flat_list.each do |story|
        if story[:estimate] && story[:estimate][1] == :range
          range_estimated += 1
        end
      end
      range_estimated
    end

    def statusses
      statusses = {}
      @document.stories_as_flat_list.each do |story|
        if story[:estimate] and story[:status]
          statusses[story[:status]] ||= 0
          statusses[story[:status]] += self.class.estimate_to_hours(story[:estimate])
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
          parts << self.class.format_range_estimated(range_estimated) if range_estimated > 0
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
      when :range
        0
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
      story_column = format_stories_count(properties[:story_count])
      "#{label.ljust(FIRST_COLUMN_WIDTH)}: #{properties[:estimate_total_in_hours]} (#{story_column})"
    end

    def self.format_unestimated(unestimated)
      "Unestimated   : #{format_stories_count(unestimated)}"
    end

    def self.format_range_estimated(range_estimated)
      "Range-estimate: #{format_stories_count(range_estimated)}"
    end

    def self.format_stories_count(count)
      count > 1 ? "#{count} stories" : 'one story'
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

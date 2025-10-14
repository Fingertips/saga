module Saga
  class Verifier
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def structure
      @structure ||= build_structure
    end

    def run
      return if structure.empty?

      reported = []
      structure.each do |title, details|
        if details[:duplicates].any?
          warning = "has multiple stories with the same id: " \
                    "#{format_sentence(details[:duplicates])}"
          if title.strip != ""
            puts "* Section #{format_title(title)} #{warning}"
          else
            puts "* Document #{warning}"
          end
        end

        structure.each do |other_title, other_details|
          next if title == other_title

          reused = details[:ids] & other_details[:ids]
          if reused.any?
            pair = [title, other_title].sort
            unless reported.include?(pair)
              puts(
                "* Sections #{format_title(title)} and #{format_title(other_title)} " \
                "share story ids: #{format_sentence(reused)}"
              )
              reported << pair
            end
          end
        end
      end
    end

    private

    def build_structure
      document.stories.each.with_object({}) do |(title, stories), structure|
        structure[title] ||= {}
        ids = stories.map { |story| story[:id] }
        structure[title][:ids] = ids
        structure[title][:duplicates] = ids.uniq.select { |id| ids.count(id) > 1 }
      end
    end

    def format_title(title)
      %("#{title}")
    end

    def format_sentence(items)
      case items.size
      when 0, 1, 2
        items.join(" and ")
      else
        format_sentence(items[..-2].join(", "), items[-1])
      end
    end
  end
end

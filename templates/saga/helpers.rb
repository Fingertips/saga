module Helpers
  def format_author(author)
    [:name, :email, :company, :website].map do |key|
      author[key]
    end.compact.join(', ')
  end

  def format_estimate(cardinality, interval)
    case interval
    when :days
      "#{cardinality}d"
    when :weeks
      "#{cardinality}w"
    else
      cardinality.to_s
    end
  end

  def format_story(story, kind=:regular)
    story_attributes = []
    story_attributes << "##{story[:id]}" if story[:id]
    story_attributes << story[:status] if story[:status]
    story_attributes << format_estimate(*story[:estimate]) if story[:estimate]
    story_attributes << "i#{story[:iteration]}" if story[:iteration]

    prefix = (kind == :nested) ? '| ' : ''
    formatted  = "#{prefix}#{story[:description]}"
    formatted << " - #{story_attributes.join(' ')}" unless story_attributes.empty?
    formatted << "\n"
    formatted << "#{prefix}  #{story[:notes]}\n" if story[:notes]
    story[:stories].each do |nested|
      formatted << format_story(nested, :nested)
    end if story[:stories]
    formatted
  end

  def format_definition(definition)
    [definition[:title], definition[:definition]].join(': ')
  end
end
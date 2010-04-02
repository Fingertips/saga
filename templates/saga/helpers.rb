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
  
  def format_story(story)
    story_attributes = []
    story_attributes << "##{story[:id]}" if story[:id]
    story_attributes << story[:status] if story[:status]
    story_attributes << format_estimate(*story[:estimate]) if story[:estimate]
    
    parts = [[story[:description], story_attributes.join(' ')].join(' - ')]
    parts << "  #{story[:notes]}" if story[:notes]
    parts.join("\n\n")
  end
  
  def format_definition(definition)
    [definition[:title], definition[:definition]].join(': ')
  end
end
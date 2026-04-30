def author(author)
  parts = []
  parts << author[:name] if author[:name]
  parts << "<a href=\"mailto:#{author[:email]}\">#{author[:email]}</a>" if author[:email]
  if author[:website] && author[:company]
    parts << "<a href=\"#{author[:website]}\">#{author[:company]}</a>"
  elsif author[:company]
    parts << author[:company]
  end
  parts.join(', ')
end

def format_header(header)
  "#{header[0, 1].upcase}#{header[1..-1].downcase}"
end

def pluralize(cardinality, singular, plural)
  [cardinality, cardinality == 1 ? singular : plural].join(' ')
end

def format_estimate(cardinality, interval)
  case interval
  when :days
    pluralize(cardinality, 'day', 'days')
  when :weeks
    pluralize(cardinality, 'week', 'days')
  when :relative
    cardinality.gsub('straightforward', "straight\u00ADforward")
  else
    cardinality.to_s
  end
end

def dom_story_id(id)
  "story#{id}"
end

def id(id)
  ["<a href=\"##{dom_story_id(id)}\" class=\"id\" title=\"ID\">#", id, '</a>'].join if id
end

def iteration(iteration)
  ['<div class="iteration" title="Iteration">', iteration, '</div>'].join if iteration
end

def status(status)
  ['<div class="status" title="Status">', status, '</div>'].join if status
end

def estimate(cardinality = nil, interval = nil)
  if cardinality
    [
      "<div class=\"estimate #{interval}\" title=\"Estimate\">",
      format_estimate(cardinality, interval),
      '</div>'
    ].join
  end
end

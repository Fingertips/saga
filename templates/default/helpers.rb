module Helpers
  def format_author(author)
    parts = []
    parts << author[:name] if author[:name]
    parts << "<a href=\"mailto:#{author[:email]}\">#{author[:email]}</a>" if author[:email]
    if author[:website] and author[:company]
      parts << "<a href=\"#{author[:website]}\">#{author[:company]}</a>"
    elsif author[:company]
      parts << author[:company]
    end
    parts.join(', ')
  end
  
  def format_header(header)
    "#{header[0,1].upcase}#{header[1..-1].downcase}"
  end
end
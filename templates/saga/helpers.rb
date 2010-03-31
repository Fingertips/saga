module Helpers
  def format_author(author)
    [:name, :email, :company, :website].map do |key|
      author[key]
    end.compact.join(', ')
  end
end
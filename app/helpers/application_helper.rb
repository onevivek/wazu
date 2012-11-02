module ApplicationHelper
  # return title on a per page basis
  def title
    base_title = "Wazu"
    if @title.nil?
      return base_title
    end 
    "#{base_title} | #{@title}"
  end
end

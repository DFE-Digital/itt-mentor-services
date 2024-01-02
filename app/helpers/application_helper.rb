module ApplicationHelper
  def current_service
    case request.host
    when ENV["CLAIMS_HOST"]
      :claims
    when ENV["PLACEMENTS_HOST"]
      :placements
    end
  end

  def external_link(link)
    return if link.blank?

    unless link.include?("http://") || link.include?("https://")
      link.insert(0, "http://")
    end
    link
  end
end

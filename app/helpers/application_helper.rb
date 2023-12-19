module ApplicationHelper
  def current_service
    case request.host
    when ENV["CLAIMS_HOST"]
      :claims
    when ENV["PLACEMENTS_HOST"]
      :placements
    end
  end
end

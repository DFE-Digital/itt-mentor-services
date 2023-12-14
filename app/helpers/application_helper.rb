module ApplicationHelper
  def current_service
    case request.host
    when ENV["CLAIMS_HOST"]
      :claims
    when ENV["PLACEMENTS_HOST"]
      :placements
    end
  end

  def root_path
    case current_service
    when :claims
      claims_root_path
    when :placements
      placements_root_path
    end
  end
end

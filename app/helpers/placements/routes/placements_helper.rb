module Placements::Routes::PlacementsHelper
  def placements_school_placement_details_path(school:, placement:, support: false)
    if support
      placements_support_school_placement_path(school, placement)
    else
      placements_school_placement_path(school, placement)
    end
  end
end

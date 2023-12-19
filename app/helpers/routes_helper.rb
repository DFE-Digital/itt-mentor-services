module RoutesHelper
  def root_path
    {
      claims: claims_root_path,
      placements: placements_root_path,
    }.fetch current_service
  end

  def support_root_path
    {
      claims: claims_support_root_path,
      placements: placements_support_root_path,
    }.fetch current_service
  end

  def organisation_index_path
    {
      claims: claims_schools_path,
      placements: placements_organisations_path,
    }.fetch current_service
  end
end

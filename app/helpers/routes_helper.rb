module RoutesHelper
  def root_path
    {
      claims: claims_root_path,
      placements: placements_root_path,
    }.fetch current_service
  end

  def support_root_path
    {
      claims: root_path, # TODO: claims support path in another PR
      placements: placements_support_root_path,
    }.fetch current_service
  end

  def organisation_index_path
    {
      claims: claims_organisations_path,
      placements: placements_organisations_path,
    }.fetch current_service
  end
end

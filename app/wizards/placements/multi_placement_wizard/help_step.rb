class Placements::MultiPlacementWizard::HelpStep < BaseStep
  delegate :school, to: :wizard

  def local_providers
    @local_providers ||= ProviderQuery.call(
      params: { location_coordinates: [school.latitude, school.longitude] },
    ).limit(2).decorate
  end
end

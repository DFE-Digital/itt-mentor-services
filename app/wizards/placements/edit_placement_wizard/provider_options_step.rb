class Placements::EditPlacementWizard::ProviderOptionsStep < Placements::EditPlacementWizard::ProviderSelectionStep
  attribute :search_param

  def providers
    @providers ||= Provider.search_name_urn_ukprn_postcode(
      search_param.downcase,
    ).decorate
  end

  def search_param
    @wizard.steps[:provider].provider_id
  end
end

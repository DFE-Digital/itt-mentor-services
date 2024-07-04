class Placements::AddOrganisationWizard::ProviderOptionsStep < Placements::AddOrganisationWizard::ProviderSelectionStep
  attribute :search_param

  def providers
    @providers ||= Provider.search_name_urn_ukprn_postcode(
      search_params.downcase,
    ).map(&:decorate)
  end

  def search_params
    @search_params ||= search_param || @wizard.steps[:provider].id
  end
end

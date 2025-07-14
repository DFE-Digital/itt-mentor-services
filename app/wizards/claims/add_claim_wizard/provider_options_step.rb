class Claims::AddClaimWizard::ProviderOptionsStep < Claims::AddClaimWizard::ProviderSelectionStep
  attribute :search_param

  def providers
    @providers ||= Claims::Provider
      .excluding_niot_providers
      .accredited
      .search_name_urn_ukprn_postcode(
        search_param.downcase,
      ).decorate
  end

  def search_param
    @wizard.steps[:provider].id
  end
end

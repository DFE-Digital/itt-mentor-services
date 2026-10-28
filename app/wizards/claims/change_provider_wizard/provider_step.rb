class Claims::ChangeProviderWizard::ProviderStep < Claims::AddClaimWizard::ProviderSelectionStep
  include Claims::ChangeProviderWizard::ProviderValidations

  attribute :name

  delegate :provider_name, to: :wizard

  def autocomplete_path_value
    "/api/academic_years/#{wizard.academic_year.id}/provider_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[postcode code]
  end
end

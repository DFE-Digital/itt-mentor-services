class Claims::AddClaimWizard::ProviderStep < Claims::AddClaimWizard::ProviderSelectionStep
  attribute :name

  delegate :provider_name, to: :wizard

  def autocomplete_path_value
    "/api/provider_suggestions"
  end

  def autocomplete_return_attributes_value
    if wizard.created_by.support_user?
      %w[postcode code]
    else
      %w[postcode]
    end
  end
end

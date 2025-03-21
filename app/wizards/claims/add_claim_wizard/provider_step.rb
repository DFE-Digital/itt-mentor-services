class Claims::AddClaimWizard::ProviderStep < Claims::AddClaimWizard::ProviderSelectionStep
  attribute :name

  def autocomplete_path_value
    "/api/provider_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[code]
  end
end

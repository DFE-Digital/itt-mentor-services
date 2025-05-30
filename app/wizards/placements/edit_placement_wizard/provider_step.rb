class Placements::EditPlacementWizard::ProviderStep < Placements::EditPlacementWizard::ProviderSelectionStep
  delegate :school, to: :wizard

  attribute :name

  def autocomplete_path_value
    "/api/provider_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[postcode code]
  end
end

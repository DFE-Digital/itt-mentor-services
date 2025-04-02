class Placements::EditPlacementWizard::ProviderStep < Placements::EditPlacementWizard::ProviderSelectionStep
  delegate :school, to: :wizard

  attribute :name

  def id_presence
    return if provider_id.present?

    errors.add(:provider_id, :provider_blank)
  end

  def autocomplete_path_value
    "/api/provider_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[code]
  end
end

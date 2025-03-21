class Placements::MultiPlacementWizard::ProviderStep < BaseStep
  attribute :provider_ids, default: []

  SELECT_ALL = "select_all".freeze

  def providers
    # This is for User Research and Testing
    Provider.where("name LIKE ?", "Test Provider %").order_by_name
  end

  def provider_ids=(value)
    super normalised_provider_ids(value)
  end

  private

  def normalised_provider_ids(selected_ids)
    return [] if selected_ids.blank?

    selected_ids.reject(&:blank?)
  end
end

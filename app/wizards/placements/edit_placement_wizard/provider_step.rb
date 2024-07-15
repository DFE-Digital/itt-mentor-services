class Placements::EditPlacementWizard::ProviderStep < Placements::BaseStep
  attribute :provider_id

  validates :provider_id, inclusion: { in: ->(step) { step.providers_for_selection.ids } }, if: -> { provider_id != "on" }

  delegate :school, to: :wizard

  def providers_for_selection
    school.partner_providers
  end

  def provider
    @provider ||= school.partner_providers.find(provider_id) if provider_id.present? && provider_id != "on"
  end
end

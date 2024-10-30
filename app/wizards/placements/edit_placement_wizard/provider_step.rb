class Placements::EditPlacementWizard::ProviderStep < BaseStep
  attribute :provider_id

  validates :provider_id, inclusion: { in: ->(step) { step.providers_for_selection.ids } }, if: -> { provider_id != NOT_KNOWN }

  delegate :school, to: :wizard

  NOT_KNOWN = "not_known".freeze

  def providers_for_selection
    school.partner_providers
  end

  def provider
    @provider ||= school.partner_providers.find(provider_id) if provider_id.present? && provider_id != NOT_KNOWN
  end
end

class Claims::AddClaimWizard::ProviderStep < BaseStep
  attribute :id

  validates :id, presence: true, inclusion: { in: ->(step) { step.providers_for_selection.ids } }

  def providers_for_selection
    Claims::Provider.private_beta_providers.select(:id, :name)
  end

  def provider
    @provider ||= Claims::Provider.private_beta_providers.find_by(id:)
  end
end

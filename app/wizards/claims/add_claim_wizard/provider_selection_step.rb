class Claims::AddClaimWizard::ProviderSelectionStep < BaseStep
  attribute :id

  validates :id, presence: true

  def provider
    @provider ||= Claims::Provider
      .excluding_niot_providers
      .eligible_for_academic_year(wizard.academic_year)
      .find_by(id:)
  end

  def scope
    self.class.name.underscore.parameterize(separator: "_")
  end
end

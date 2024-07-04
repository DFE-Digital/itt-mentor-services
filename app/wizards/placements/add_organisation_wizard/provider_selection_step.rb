class Placements::AddOrganisationWizard::ProviderSelectionStep < Placements::AddOrganisationWizard::BaseStep
  attribute :id

  validates :id, presence: true
  validate :provider_already_onboarded?

  def provider
    @provider ||= Provider.find_by(id:)
  end

  def provider_already_onboarded?
    return if provider.blank?

    errors.add(:id, :already_added, provider_name: provider.name) if provider.placements_service?
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements_#{wizard_name}_#{step_name}"
  end
end

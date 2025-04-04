class Placements::EditPlacementWizard::ProviderSelectionStep < BaseStep
  attribute :provider_id

  validates :provider_id, presence: true

  delegate :name, to: :provider, prefix: true, allow_nil: true

  def provider
    @provider ||= Provider.find_by(id: provider_id)
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements_#{wizard_name}_#{step_name}"
  end

  private

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end
end

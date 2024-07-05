class Placements::AddOrganisationWizard::OrganisationSelectionStep < Placements::AddOrganisationWizard::BaseStep
  attribute :id

  validate :id_presence
  validate :organisation_already_onboarded?

  def organisation
    @organisation ||= wizard.organisation_model&.find_by(id:)
  end

  def id_presence
    return if id.present?

    errors.add(:id, :blank, organisation_type: wizard.organisation_type)
  end

  def organisation_already_onboarded?
    return if organisation.blank? || !organisation.placements_service?

    errors.add(
      :id,
      :already_added,
      organisation_name: organisation.name,
      organisation_type: wizard.organisation_type,
    )
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements_#{wizard_name}_#{step_name}"
  end
end

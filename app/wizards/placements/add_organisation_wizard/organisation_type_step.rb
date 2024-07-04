class Placements::AddOrganisationWizard::OrganisationTypeStep < Placements::AddOrganisationWizard::BaseStep
  ITT_PROVIDER = "provider".freeze
  SCHOOL = "school".freeze
  ORGANISATION_TYPES = [ITT_PROVIDER, SCHOOL].freeze

  attribute :organisation_type

  validates :organisation_type, presence: true, inclusion: { in: ORGANISATION_TYPES }

  def organisation_types_for_selection
    [
      OpenStruct.new(
        name: I18n.t("placements.wizards.add_organisation_wizard.organisation_type_step.#{ITT_PROVIDER}"),
        value: ITT_PROVIDER,
      ),
      OpenStruct.new(
        name: I18n.t("placements.wizards.add_organisation_wizard.organisation_type_step.#{SCHOOL}"),
        value: SCHOOL,
      ),
    ]
  end

  def provider?
    organisation_type == ITT_PROVIDER
  end
end

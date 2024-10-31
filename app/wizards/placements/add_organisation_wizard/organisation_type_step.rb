class Placements::AddOrganisationWizard::OrganisationTypeStep < BaseStep
  PROVIDER = "provider".freeze
  SCHOOL = "school".freeze
  ORGANISATION_TYPES = [PROVIDER, SCHOOL].freeze

  attribute :organisation_type

  validates :organisation_type, presence: true, inclusion: { in: ORGANISATION_TYPES }

  def organisation_types_for_selection
    [
      OpenStruct.new(
        name: I18n.t("wizards.placements.add_organisation_wizard.organisation_type_step.#{PROVIDER}"),
        value: PROVIDER,
      ),
      OpenStruct.new(
        name: I18n.t("wizards.placements.add_organisation_wizard.organisation_type_step.#{SCHOOL}"),
        value: SCHOOL,
      ),
    ]
  end

  def provider?
    organisation_type == PROVIDER
  end

  def school?
    organisation_type == SCHOOL
  end
end

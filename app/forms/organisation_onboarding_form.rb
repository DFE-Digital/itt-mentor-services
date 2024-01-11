class OrganisationOnboardingForm
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  attr_accessor :organisation_type

  ITT_PROVIDER = "itt_provider".freeze
  SCHOOL = "school".freeze
  ORGANISATION_TYPES = [ITT_PROVIDER, SCHOOL].freeze

  validates :organisation_type, presence: true, inclusion: { in: ORGANISATION_TYPES }

  def onboarding_url
    return unless valid?

    if organisation_type == ITT_PROVIDER
      new_placements_support_provider_path
    else
      new_placements_support_school_path
    end
  end

  def options
    ORGANISATION_TYPES.map do |org_type|
      OpenStruct.new(id: org_type, name: I18n.t(org_type))
    end
  end
end

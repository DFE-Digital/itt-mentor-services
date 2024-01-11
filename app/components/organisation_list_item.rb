class OrganisationListItem < ApplicationComponent
  attr_reader :organisation, :organisation_type, :organisation_url

  def initialize(
    organisation:,
    organisation_type:,
    organisation_url:,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @organisation = organisation
    @organisation_type = organisation_type
    @organisation_url = organisation_url
  end
end

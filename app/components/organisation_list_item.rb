class OrganisationListItem < ApplicationComponent
  attr_reader :organisation, :organisation_url, :show_details

  def initialize(
    organisation:,
    organisation_url:,
    show_details: false,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @organisation = organisation
    @organisation_url = organisation_url
    @show_details = show_details
  end
end

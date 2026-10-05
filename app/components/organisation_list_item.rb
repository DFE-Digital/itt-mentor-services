class OrganisationListItem < ApplicationComponent
  attr_reader :organisation, :organisation_url, :show_details, :show_tag

  def initialize(
    organisation:,
    organisation_url:,
    show_details: false,
    show_tag: false,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @organisation = organisation
    @organisation_url = organisation_url
    @show_details = show_details
    @show_tag = show_tag
  end
end

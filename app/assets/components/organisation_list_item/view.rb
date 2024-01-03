class OrganisationListItem::View < GovukComponent::Base
  attr_reader :organisation, :organisation_type, :organisation_url

  def initialize(organisation:, organisation_type:, organisation_url:)
    @organisation = organisation
    @organisation_type = organisation_type
    @organisation_url = organisation_url
  end
end

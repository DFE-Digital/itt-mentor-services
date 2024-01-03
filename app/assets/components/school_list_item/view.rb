class SchoolListItem::View < GovukComponent::Base
  def initialize(school:)
    @school = school
  end

  def call
    # TODO: Add school url
    render OrganisationListItem::View.new(
             organisation: @school,
             organisation_url: "#",
             organisation_type: "school",
           )
  end
end

class Placement::SummaryComponent < ApplicationComponent
  with_collection_parameter :placement
  attr_reader :placement, :school, :provider, :location_coordinates

  def initialize(provider:, placement:, location_coordinates: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @placement = placement.decorate
    @school = @placement.school
    @location_coordinates = location_coordinates
  end

  def distance_from_location
    distance = @school.distance_to(@location_coordinates).round(1)
    I18n.t("components.placement.summary_component.distance_in_miles", distance:)
  end
end

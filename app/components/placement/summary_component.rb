class Placement::SummaryComponent < ApplicationComponent
  with_collection_parameter :placement
  attr_reader :placement, :school, :provider, :location_coordinates, :search_location

  def initialize(provider:, placement:, location_coordinates: nil, search_location: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @placement = placement.decorate
    @school = @placement.school
    @location_coordinates = location_coordinates
    @search_location = search_location

    calculate_travel_time
  end

  def distance_from_location
    distance = @school.distance_to(@location_coordinates).round(1)
    I18n.t("components.placement.summary_component.distance_in_miles", distance:)
  end

  def calculate_travel_time
    return if search_location.blank?

    @calculate_travel_time ||= Placements::TravelTime.call(
      origin_address: search_location,
      destinations: [@school],
    )
  end
end

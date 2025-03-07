class School::SummaryComponent < ApplicationComponent
  with_collection_parameter :school
  attr_reader :school, :provider, :location_coordinates

  def initialize(school:, provider:, location_coordinates: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @school = school.decorate
    @location_coordinates = location_coordinates
  end

  def distance_from_location
    distance = school.distance_to(@location_coordinates).round(1)
    I18n.t("components.placement.summary_component.distance_in_miles", distance:)
  end

  def available_placements
    school.available_placement_subjects.pluck(:name).join(", ")
  end

  def also_hosting_placements
    school.unavailable_placement_subjects.pluck(:name).join(", ")
  end

  def placement_status
    academic_year_name = latest_academic_year_name

    I18n.t(
      "components.school.summary_component.#{academic_year_name ? "placements_hosted" : "placements_never_hosted"}",
      academic_year_name:,
    )
  end

  private

  def latest_academic_year_name
    current_academic_year_start = Placements::AcademicYear.current.starts_on

    Placements::AcademicYear.where(id: school.placements.pluck(:academic_year_id),
                                   ends_on: ..current_academic_year_start)
                            .order_by_date.pick(:name)
  end

  def not_open?
    school.current_hosting_interest_appetite == "not_open" || school.current_hosting_interest_appetite.blank?
  end
end

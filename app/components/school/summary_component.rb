class School::SummaryComponent < ApplicationComponent
  with_collection_parameter :school
  attr_reader :school, :provider, :location_coordinates

  delegate :school_contact, to: :school, prefix: false, allow_nil: true

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

  def available_placements_count
    school.available_placements.count
  end

  def unavailable_placements_count
    school.unavailable_placements.count
  end

  def placement_status
    academic_year_name = latest_academic_year_name

    I18n.t(
      "components.school.summary_component.#{academic_year_name ? "placements_hosted" : "placements_never_hosted"}",
      academic_year_name:,
    )
  end

  private
  
  def latest_academic_year
    @latest_academic_year ||= Placements::AcademicYear.where(id: school.placements.pluck(:academic_year_id),
                                                             ends_on: ..current_academic_year_start)
                                                     .order_by_date.first
  end

  def latest_academic_year_name
    latest_academic_year&.name
  end

  def latest_academic_year_placements_count
    school.placements.where(academic_year: latest_academic_year).count
  end

  def latest_academic_year_placements_names
    school.placements.joins(:subject).where(academic_year: latest_academic_year).pluck("subject.name").join(", ")
  end

  def previous_academic_year_placements_count
    school.placements.where(academic_year: Placements::AcademicYear.current.previous).count
  end

  def current_academic_year_start
    @current_academic_year ||= Placements::AcademicYear.current.starts_on
  end

  def not_open?
    school.current_hosting_interest_appetite == "not_open" || school.current_hosting_interest_appetite.blank?
  end
end

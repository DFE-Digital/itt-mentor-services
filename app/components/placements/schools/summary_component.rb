class Placements::Schools::SummaryComponent < ApplicationComponent
  with_collection_parameter :school
  attr_reader :school, :provider, :location_coordinates

  delegate :school_contact, :current_hosting_interest_appetite, to: :school, allow_nil: true
  delegate :full_name, :email_address, to: :school_contact, prefix: true, allow_nil: true
  delegate :available_placements, :unavailable_placements, to: :school, prefix: true, allow_nil: true

  def initialize(school:, provider:, location_coordinates: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @school = school.decorate
    @location_coordinates = location_coordinates
  end

  def distance_from_location
    distance = school.distance_to(location_coordinates).round(1)
    I18n.t("components.placement.summary_component.distance_in_miles", distance:)
  end

  def available_placements_count
    @available_placements_count ||= school_available_placements.count
  end

  def unavailable_placements_count
    @unavailable_placements_count ||= school_unavailable_placements.count
  end

  def placement_status
    I18n.t(
      "components.school.summary_component.#{latest_academic_year_name ? "placements_hosted" : "placements_never_hosted"}",
      academic_year_name: latest_academic_year_name,
    )
  end

  def unfilled_subjects
    @unfilled_subjects ||= Subject.where(id: unfilled_subject_ids)
  end

  def filled_subjects
    @filled_subjects ||= Subject.where(id: filled_subject_ids)
  end

  def open_to_hosting?
    current_hosting_interest_appetite == "actively_looking"
  end

  def not_open_to_hosting?
    current_hosting_interest_appetite.blank? || current_hosting_interest_appetite == "not_open"
  end

  private

  def latest_academic_year
    @latest_academic_year ||= academic_years_for_school.order_by_date.first
  end

  def latest_academic_year_name
    latest_academic_year&.name
  end

  def previous_academic_year_placements_count
    @previous_academic_year_placements_count ||= school.placements.where(academic_year: Placements::AcademicYear.current.previous).count
  end

  def academic_years_for_school
    Placements::AcademicYear.where(id: school.placements.pluck(:academic_year_id), ends_on: ..current_academic_year_start)
  end

  def current_academic_year_start
    @current_academic_year_start ||= Placements::AcademicYear.current.starts_on
  end

  def unfilled_subject_ids
    school.placements.where(academic_year_id: Placements::AcademicYear.current.id, provider_id: nil).pluck(:subject_id)
  end

  def filled_subject_ids
    school.placements.where(academic_year_id: Placements::AcademicYear.current.id).where.not(provider_id: nil).pluck(:subject_id)
  end
end

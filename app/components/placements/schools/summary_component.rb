class Placements::Schools::SummaryComponent < ApplicationComponent
  with_collection_parameter :school
  attr_reader :school, :provider, :location_coordinates, :academic_year

  delegate :school_contact, to: :school, allow_nil: true
  delegate :full_name, :email_address, to: :school_contact, prefix: true, allow_nil: true
  delegate :available_placements, :unavailable_placements, :send_placements,
           :potential_send_placements?, to: :school, prefix: true, allow_nil: true

  def initialize(school:, provider:, academic_year:, location_coordinates: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @school = school.decorate
    @academic_year = academic_year
    @location_coordinates = location_coordinates
  end

  def link_to_school
    if (open_to_hosting? && academic_year_placements.exists?) || interested_in_hosting?
      placements_placements_provider_find_path(provider, school)
    else
      school_details_placements_provider_find_path(provider, school)
    end
  end

  def distance_from_location
    distance = school.distance_to(location_coordinates).round(1)
    I18n.t("components.placement.summary_component.distance_in_miles", distance:)
  end

  def has_available_placements?
    school_available_placements(academic_year:).exists?
  end

  def has_unavailable_placements?
    school_unavailable_placements(academic_year:).exists?
  end

  def academic_year_placements
    @academic_year_placements ||= school.placements.where(academic_year:)
  end

  def available_placements_count
    @available_placements_count ||= school_available_placements(academic_year:).count
  end

  def unavailable_placements_count
    @unavailable_placements_count ||= school_unavailable_placements(academic_year:).count
  end

  def send_placements_count
    @send_placements_count ||= school_send_placements(academic_year:).count
  end

  def open_to_hosting?
    current_hosting_interest_appetite == "actively_looking"
  end

  def placement_availability_unknown?
    current_hosting_interest_appetite.blank?
  end

  def interested_in_hosting?
    current_hosting_interest_appetite == "interested"
  end

  def not_open_to_hosting?
    current_hosting_interest_appetite == "not_open"
  end

  def offering_send?
    send_placements_count.positive? ||
      school_potential_send_placements?
  end

  private

  def previous_academic_year_placements_count
    @previous_academic_year_placements_count ||= school.placements.where(academic_year: academic_year.previous).count
  end

  def unfilled_subject_ids
    school.placements.where(academic_year_id: academic_year.id, provider_id: nil).pluck(:subject_id)
  end

  def filled_subject_ids
    school.placements.where(academic_year_id: academic_year.id).where.not(provider_id: nil).pluck(:subject_id)
  end

  def current_hosting_interest_appetite
    @current_hosting_interest_appetite ||= school.current_hosting_interest(academic_year:)&.appetite
  end
end

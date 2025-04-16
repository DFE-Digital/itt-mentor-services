class Placements::Providers::FindController < Placements::ApplicationController
  before_action :set_provider
  before_action :school, only: %i[placements placement_information school_details]
  before_action :load_placements_and_subjects, only: %i[placements placement_information school_details]
  helper_method :filter_form, :location_coordinates

  def index
    @subjects = filter_subjects_by_phase
    query = Placements::SchoolsQuery.call(params: query_params)
    @pagy, @schools = pagy(all_schools.merge(query).distinct)
    calculate_travel_time
  end

  def placements; end

  def placement_information
    @placements_last_offered = placements_last_offered
  end

  def school_details; end

  private

  def school
    @school ||= Placements::School.find(params[:id]).decorate
  end

  def load_placements_and_subjects
    @filled_placements = filled_placements(@school).decorate
    @unfilled_placements = unfilled_placements(@school).decorate
    @filled_subjects = subjects_for_placements(@filled_placements)
    @unfilled_subjects = subjects_for_placements(@unfilled_placements)
  end

  def calculate_travel_time
    return if search_location.blank?

    Placements::TravelTime.call(
      origin_address: search_location,
      destinations: @schools.uniq,
    )
  end

  def filter_form
    @filter_form ||= Placements::Schools::FilterForm.new(@provider, filter_params)
  end

  def location_coordinates
    return if search_location.blank?

    @location_coordinates ||= Geocoder::Search.call(search_location).coordinates
  end

  def unfilled_placements(school)
    school.placements
          .where(academic_year_id: Placements::AcademicYear.current.id, provider_id: nil)
          .distinct
  end

  def filled_placements(school)
    school.placements
          .where(academic_year_id: Placements::AcademicYear.current.id)
          .where.not(provider_id: nil)
          .distinct
  end

  def subjects_for_placements(placements)
    Subject.where(id: placements.pluck(:subject_id))
  end

  def search_location
    @search_location ||= params[:search_location] || params.dig(:filters, :search_location)
  end

  def filter_params
    params.fetch(:filters, {}).permit(
      :search_location,
      :search_by_name,
      subject_ids: [],
      phases: [],
      itt_statuses: [],
      last_offered_placements_academic_year_ids: [],
      trained_mentors: [],
    )
  end

  def query_params
    {
      filters: filter_form.query_params,
      location_coordinates: location_coordinates,
      current_provider: @provider,
    }
  end

  def all_schools
    @all_schools ||= Placements::School.all
  end

  def filter_subjects_by_phase
    scope = if filter_form.primary_only?
              Subject.primary
            elsif filter_form.secondary_only?
              Subject.secondary
            else
              Subject
            end
    scope.order_by_name.select(:id, :name)
  end

  def placements_last_offered
    @school.placements
           .where(academic_year: Placements::AcademicYear.current.previous)
           .decorate
           .includes(:academic_year)
           .group_by(&:academic_year)
  end
end

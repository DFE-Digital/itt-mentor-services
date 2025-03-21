class Placements::Providers::FindController < Placements::ApplicationController
  before_action :set_provider
  helper_method :filter_form, :location_coordinates

  def index
    @subjects = Subject.all
    query = Placements::SchoolsQuery.call(params: query_params)
    @pagy, @schools = pagy(all_schools.merge(query).distinct)
    calculate_travel_time
  end

  def show
    @school = Placements::School.find(params[:id])
  end

  def placements
    @school = Placements::School.find(params[:id])
    @unfilled_placements = @school.placements.where(academic_year_id: Placements::AcademicYear.current.id, provider_id: nil).distinct.decorate
    @filled_placements = @school.placements.where(academic_year_id: Placements::AcademicYear.current.id).where.not(provider_id: nil).distinct.decorate
  end

  def placement_information
    @school = Placements::School.find(params[:id])
    @placements_last_offered = @school.placements.where(academic_year: Placements::AcademicYear.current.previous).decorate
    @unfilled_placements = @school.placements.where(academic_year_id: Placements::AcademicYear.current.id, provider_id: nil).distinct
    @unfilled_subjects = Subject.where(id: @unfilled_placements.pluck(:subject_id))
    @filled_subjects = Subject.where(id: @school.placements.where(academic_year_id: Placements::AcademicYear.current.id).where.not(provider_id: nil).pluck(:subject_id))
  end

  def school_details
    @school = Placements::School.find(params[:id]).decorate
    @unfilled_placements = @school.placements.where(academic_year_id: Placements::AcademicYear.current.id, provider_id: nil).distinct
    @unfilled_subjects = Subject.where(id: @unfilled_placements.pluck(:subject_id))
    @filled_subjects = Subject.where(id: @school.placements.where(academic_year_id: Placements::AcademicYear.current.id).where.not(provider_id: nil).pluck(:subject_id))
  end

  private

  def calculate_travel_time
    return if search_location.blank?

    Placements::TravelTime.call(
      origin_address: search_location,
      destinations: @schools.uniq, # travel times are attributes on decorated schools
    )
  end

  def filter_form
    @filter_form ||= Placements::Schools::FilterForm.new(@provider, filter_params)
  end

  def search_location
    @search_location ||= params[:search_location] ||
      params.dig(:filters, :search_location)
  end

  def location_coordinates
    return if search_location.blank?

    @location_coordinates ||= begin
      location = Geocoder::Search.call(
        search_location,
      )
      location.coordinates
    end
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
      location_coordinates:,
      current_provider: @provider,
    }
  end

  def all_schools
    @all_schools ||= Placements::School.all
  end

  def compact_school_attribute_values(attribute)
    all_schools.where.not(attribute => nil)
               .distinct(attribute).order(attribute).pluck(attribute)
  end
end

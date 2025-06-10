class Placements::Providers::FindController < Placements::ApplicationController
  before_action :set_provider
  before_action :selected_academic_year
  before_action :load_placements_and_subjects, only: %i[placements placement_information school_details]
  before_action :store_filter_params, only: %i[index]
  helper_method :filter_form, :location_coordinates

  def index
    @subjects = filter_subjects_by_phase
    @schools_i_work_with = @provider.partner_schools.order_by_name
    query = Placements::SchoolsQuery.call(academic_year: selected_academic_year, params: query_params)
    @pagy, @schools = pagy(all_schools.merge(query).distinct)
    calculate_travel_time
  end

  def placements
    @interested_in_hosting = school.current_hosting_interest(academic_year: selected_academic_year).interested?
  end

  def placement_information
    @placements_last_offered = placements_last_offered
  end

  def school_details; end

  private

  def school
    @school ||= School.find(params[:id]).decorate
  end

  def load_placements_and_subjects
    @filled_placements = filled_placements(school).decorate
    @unfilled_placements = unfilled_placements(school).decorate
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
          .where(academic_year_id: selected_academic_year.id, provider_id: nil)
          .distinct
  end

  def filled_placements(school)
    school.placements
          .where(academic_year_id: selected_academic_year.id)
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
      schools_i_work_with_ids: [],
      subject_ids: [],
      phases: [],
      year_groups: [],
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
    @all_schools ||= School.all
  end

  def filter_subjects_by_phase
    return Subject.none if filter_form.primary_only?

    Subject.secondary.order_by_name.select(:id, :name)
  end

  def placements_last_offered
    school.placements
           .where(academic_year: selected_academic_year.previous)
           .decorate
           .includes(:academic_year)
           .group_by(&:academic_year)
  end

  def selected_academic_year
    @selected_academic_year ||= current_user.selected_academic_year
  end

  def store_filter_params
    session["find_filter_params"] = { filters: filter_params }
  end
end

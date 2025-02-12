class Placements::Providers::PlacementsController < Placements::ApplicationController
  before_action :set_provider
  helper_method :filter_form, :location_coordinates

  def index
    @current_academic_year = Placements::AcademicYear.current.decorate
    @next_academic_year = @current_academic_year.next.decorate
    @subjects = filter_subjects_by_phase
    @establishment_groups = compact_school_attribute_values(:group)
    @schools = schools_scope.order_by_name.select(:id, :name)
    @year_groups ||= Placement.year_groups_as_options
    @terms = Placements::Term.order_by_term.select(:id, :name)
    query = Placements::PlacementsQuery.call(params: query_params)
    @pagy, @placements = pagy(placements.merge(query))
    @placements = @placements.decorate

    filter_schools_by_phase
    calculate_travel_time
  end

  def show
    @placement = placements.find(params.require(:id)).decorate
    @school = @placement.school
  end

  private

  def placements
    policy_scope([:provider, Placement.all])
  end

  def schools_scope
    if filter_params[:only_partner_schools].present?
      @provider.partner_schools
    else
      Placements::School.all
    end
  end

  def filter_form
    @filter_form ||= Placements::Placements::FilterForm.new(@provider, filter_params)
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
      # latitude and longitude
      location.coordinates
    end
  end

  def calculate_travel_time
    return if search_location.blank?

    Placements::TravelTime.call(
      origin_address: search_location,
      destinations: @placements.map(&:school).uniq, # travel times are attributes on decorated schools
    )
  end

  def filter_params
    params.fetch(:filters, {}).permit(
      :placements_to_show,
      :academic_year_id,
      :only_partner_schools,
      :search_location,
      school_ids: [],
      subject_ids: [],
      term_ids: [],
      phases: [],
      establishment_groups: [],
      year_groups: [],
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
    @all_schools ||= School.all
  end

  def compact_school_attribute_values(attribute)
    all_schools.where.not(attribute => nil)
               .distinct(attribute).order(attribute).pluck(attribute)
  end

  def filter_subjects_by_phase
    if filter_form.primary_only?
      Subject.primary
    elsif filter_form.secondary_only?
      Subject.secondary
    else
      Subject
    end.order_by_name.select(:id, :name)
  end

  def filter_schools_by_phase
    if filter_form.primary_only?
      @schools = @schools.where.not(phase: "Secondary")
    elsif filter_form.secondary_only?
      @schools = @schools.where.not(phase: "Primary")
    end
  end
end

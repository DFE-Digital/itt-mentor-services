class Placements::Providers::PlacementsController < Placements::ApplicationController
  before_action :set_current_provider
  helper_method :filter_form, :location_coordinates

  def index
    @current_academic_year = Placements::AcademicYear.current.decorate
    @next_academic_year = @current_academic_year.next.decorate
    @subjects = Subject.order_by_name.select(:id, :name)
    @establishment_groups = compact_school_attribute_values(:group)
    @schools = schools_scope.order_by_name.select(:id, :name)
    @year_groups ||= Placement.year_groups_as_options
    @terms = Placements::Term.order_by_term.select(:id, :name)
    scope = policy_scope(Placements::PlacementsQuery.call(params: query_params))

    @pagy, @placements = pagy(scope)
  end

  def show
    @placement = Placement.find(params[:id]).decorate
    @school = @placement.school
  end

  private

  def schools_scope
    if filter_params[:only_partner_schools].present?
      @provider.partner_schools
    else
      Placements::School.all
    end
  end

  def set_current_provider
    @provider = current_user.providers.find(params[:provider_id])
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

  def filter_params
    params.fetch(:filters, {}).permit(
      :placements_to_show,
      :academic_year_id,
      :only_partner_schools,
      :search_location,
      school_ids: [],
      subject_ids: [],
      term_ids: [],
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
end

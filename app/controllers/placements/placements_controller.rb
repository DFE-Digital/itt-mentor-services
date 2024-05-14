class Placements::PlacementsController < ApplicationController
  before_action :set_provider
  helper_method :filter_form, :location_coordinates

  def index
    @subjects = Subject.order_by_name.select(:id, :name)
    @establishment_groups = compact_school_attribute_values(:group)
    @schools = schools_scope.order_by_name.select(:id, :name)

    @pagy, @placements = pagy(
      Placements::PlacementsQuery.call(
        params: query_params,
      ),
    )
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

  def set_provider
    @provider = Placements::Provider.first
  end

  def filter_form
    @filter_form ||= Placements::Placements::FilterForm.new(filter_params)
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
      :only_available_placements,
      :only_partner_schools,
      school_ids: [],
      subject_ids: [],
      establishment_groups: [],
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

class Placements::Providers::PlacementsController < ApplicationController
  before_action :set_provider
  helper_method :filter_form

  def index
    @subjects = Subject.order_by_name.select(:id, :name)
    @school_types = compact_school_attribute_values(:type_of_establishment)
    @schools = Placements::School.select(:id, :name)
    @partner_schools = @provider.partner_schools.select(:id, :name)

    @pagy, @placements = pagy(
      Placements::PlacementsQuery.call(
        params: filter_form.query_params,
      ),
    )
  end

  def show
    @placement = Placement.find(params[:id]).decorate
    @school = @placement.school
  end

  private

  def set_provider
    @provider = Placements::Provider.find(params[:provider_id])
  end

  def filter_form
    @filter_form ||= Placements::Placements::FilterForm.new(filter_params)
  end

  def filter_params
    params.fetch(:filters, {}).permit(
      partner_school_ids: [],
      school_ids: [],
      subject_ids: [],
      school_types: [],
    )
  end

  def all_schools
    @all_schools ||= School.all
  end

  def compact_school_attribute_values(attribute)
    all_schools.where.not(attribute => nil)
      .distinct(attribute).order(attribute).pluck(attribute)
  end
end

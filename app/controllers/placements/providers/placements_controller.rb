class Placements::Providers::PlacementsController < ApplicationController
  before_action :set_provider
  helper_method :filter_form

  def index
    schools = Placements::School.order_by_name
    @subjects = Subject.order_by_name
    @school_types = schools.pluck(:type_of_establishment).uniq.compact.sort
    @genders = schools.pluck(:gender).uniq.compact.sort
    @religious_characters = schools.pluck(:religious_character).uniq.compact.sort
    @ofsted_ratings = schools.pluck(:rating).uniq.compact.sort
    @schools = schools.select(:id, :name, :phase)

    @pagy, @placements = pagy(
      Placements::PlacementsQuery.call(
        params: filter_form.query_params,
      ).decorate,
    )
  end

  private

  def set_provider
    @provider = Provider.find(params[:provider_id])
  end

  def filter_form
    @filter_form ||= Placements::Placements::FilterForm.new(filter_params)
  end

  def filter_params
    params.fetch(:filters, {}).permit(
      school_phases: [],
      school_ids: [],
      subject_ids: [],
      school_types: [],
      genders: [],
      religious_characters: [],
      ofsted_ratings: [],
    )
  end
end

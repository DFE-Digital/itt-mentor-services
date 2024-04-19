class Placements::Providers::PlacementsController < ApplicationController
  before_action :set_provider
  helper_method :filter_form

  def index
    @subjects = Subject.order_by_name
    @school_types = compact_school_attribute_values(:type_of_establishment)
    @genders = compact_school_attribute_values(:gender)
    @religious_characters = compact_school_attribute_values(:religious_character)
    @ofsted_ratings = compact_school_attribute_values(:rating)
    @schools = Placements::School.order_by_name.select(:id, :name, :phase)

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

  def all_schools
    @all_schools ||= School.all
  end

  def compact_school_attribute_values(attribute)
    if attribute == :rating
      [
        "Outstanding",
        "Good",
        "Requires improvement",
        "Inadequate",
        "Serious Weaknesses",
      ]
    else
      all_schools.pluck(attribute).uniq.compact.sort
    end
  end
end

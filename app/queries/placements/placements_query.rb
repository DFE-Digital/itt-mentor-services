class Placements::PlacementsQuery < ApplicationQuery
  def call
    scope = Placement.includes(:school, :subjects)

    scope = school_condition(scope)
    scope = partner_school_condition(scope)
    scope = subject_condition(scope)
    scope = school_type_condition(scope)
    scope = only_available_placements_condition(scope)
    order_condition(scope)
  end

  private

  def school_condition(scope)
    return scope if filter_params[:school_ids].blank?

    scope.where(school_id: filter_params[:school_ids])
  end

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.where(subjects: { id: filter_params[:subject_ids] })
  end

  def school_type_condition(scope)
    return scope if filter_params[:school_types].blank?

    scope.where(schools: { type_of_establishment: filter_params[:school_types] })
  end

  def partner_school_condition(scope)
    return scope if filter_params[:only_partner_schools].blank?

    provider = params[:current_provider]
    scope.where(school_id: provider.partner_schools.select(:id))
  end

  def only_available_placements_condition(scope)
    return scope if filter_params[:only_available_placements].blank?

    scope.where(provider_id: nil)
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def order_condition(scope)
    if params[:location_coordinates].present?
      school_ids = Placements::School.near(
        params[:location_coordinates],
        Geocoder::Search::UK_LENGTH,
        order: :distance,
      ).map(&:id)
      scope.order_by_location_and_subject(school_ids)
    else
      scope.order_by_subject_school_name
    end
  end
end

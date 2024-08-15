class Placements::PlacementsQuery < ApplicationQuery
  MAX_LOCATION_DISTANCE = 50

  def call
    scope = Placement.includes(:school, :subject, :additional_subjects, :provider)

    scope = school_condition(scope)
    scope = partner_school_condition(scope)
    scope = subject_condition(scope)
    scope = placements_to_show_condition(scope)
    scope = year_group_condition(scope)
    order_condition(scope)
  end

  private

  def school_condition(scope)
    return scope if filter_params[:school_ids].blank?

    scope.where(school_id: filter_params[:school_ids])
  end

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.where(subject_id: filter_params[:subject_ids])
         .or(scope.where(additional_subjects: { id: filter_params[:subject_ids] }))
  end

  def partner_school_condition(scope)
    return scope if filter_params[:only_partner_schools].blank?

    provider = params[:current_provider]
    scope.where(school_id: provider.partner_schools.select(:id))
  end

  def placements_to_show_condition(scope)
    case filter_params[:placements_to_show]
    when "available_placements"
      scope.where(provider_id: nil)
    when "assigned_to_me"
      scope.where(provider_id: params[:current_provider].id)
    else
      scope
    end
  end

  def year_group_condition(scope)
    return scope if filter_params[:year_groups].blank?

    scope.where(year_group: filter_params[:year_groups])
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def school_ids_near_location(location_coordinates)
    Placements::School.near(
      location_coordinates,
      MAX_LOCATION_DISTANCE,
      order: :distance,
    ).map(&:id)
  end

  def order_condition(scope)
    if params[:location_coordinates].present?
      school_ids = school_ids_near_location(
        params[:location_coordinates],
      )

      scope.where(school_id: school_ids)
        .order_by_school_ids(school_ids)
        .order("subjects.name")
    else
      scope.order_by_subject_school_name
    end
  end
end

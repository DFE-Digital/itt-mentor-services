class Placements::PlacementsQuery < ApplicationQuery
  def call
    scope = Placement.includes(:school, :subjects)

    scope = school_condition(scope)
    scope = subject_condition(scope)
    scope = school_type_condition(scope)
    scope = partner_school_condition(scope)
    scope = available_condition(scope)
    scope.order_by_subject_school_name
  end

  private

  def school_condition(scope)
    return scope if params[:school_ids].blank?

    scope.where(school_id: params[:school_ids])
  end

  def subject_condition(scope)
    return scope if params[:subject_ids].blank?

    scope.where(subjects: { id: params[:subject_ids] })
  end

  def school_type_condition(scope)
    return scope if params[:school_types].blank?

    scope.where(schools: { type_of_establishment: params[:school_types] })
  end

  def partner_school_condition(scope)
    return scope if params[:partner_school_ids].blank?

    scope.where(school_id: params[:partner_school_ids])
  end

  def available_condition(scope)
    return scope if params[:available].blank?

    scope.where(provider_id: nil)
  end
end

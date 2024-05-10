class Placements::PlacementsQuery < ApplicationQuery
  def call
    scope = set_initial_scope
    scope = school_condition(scope)
    scope = subject_condition(scope)
    scope = school_type_condition(scope)
    scope = only_available_placements_condition(scope)
    scope.order_by_subject_school_name
  end

  private

  def set_initial_scope
    if partner_schools_present?
      scope_with_partner_schools
    else
      Placement.includes(:school, :subjects)
    end
  end

  def scope_with_partner_schools
    provider = Placements::Provider.find(params[:partner_schools].first)
    Placement.where(school_id: provider.partner_schools.ids).includes(:school, :subjects)
  end

  def partner_schools_present?
    params[:partner_schools]&.compact_blank!.present?
  end

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
    return scope if filter_params[:partner_school_ids].blank?

    scope.where(school_id: filter_params[:partner_school_ids])
  end

  def only_available_placements_condition(scope)
    return scope if filter_params[:only_available_placements].blank?

    scope.where(provider_id: nil)
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end
end

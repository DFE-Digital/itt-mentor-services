class Placements::PlacementsQuery < ApplicationQuery
  def call
    scope = Placement.includes(:school, :subjects)

    scope = phase_condition(scope)
    scope = school_condition(scope)
    scope = subject_condition(scope)
    scope = school_type_condition(scope)
    scope = gender_condition(scope)
    scope = religious_character_condition(scope)
    scope = ofsted_rating_condition(scope)
    scope.order_by_school_name
  end

  private

  def phase_condition(scope)
    return scope if params[:school_phases].blank?

    scope.where(schools: { phase: params[:school_phases] })
  end

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

  def gender_condition(scope)
    return scope if params[:genders].blank?

    scope.where(schools: { gender: params[:genders] })
  end

  def religious_character_condition(scope)
    return scope if params[:religious_characters].blank?

    scope.where(schools: { religious_character: params[:religious_characters] })
  end

  def ofsted_rating_condition(scope)
    return scope if params[:ofsted_ratings].blank?

    scope.where(schools: { rating: params[:ofsted_ratings] })
  end
end

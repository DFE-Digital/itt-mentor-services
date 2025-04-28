class Placements::PlacementsQuery < ApplicationQuery
  def call
    scope = Placement.includes(:school, :subject, :additional_subjects)

    scope = school_condition(scope)
    scope = subject_condition(scope)
    scope = phase_condition(scope)
    order_condition(scope)
  end

  private

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.where(subject_id: filter_params[:subject_ids])
         .or(scope.where(additional_subjects: { id: filter_params[:subject_ids] }))
  end

  def school_condition(scope)
    return scope if filter_params[:school_ids].blank?

    scope.where(school_id: filter_params[:school_ids])
  end

  def phase_condition(scope)
    return scope if filter_params[:phases].blank?

    if filter_params[:phases].include?("primary") && filter_params[:phases].include?("secondary")
      scope.joins(:subject)
    else
      scope.joins(:subject).where(subjects: { subject_area: filter_params[:phases] })
    end
  end

  def year_group_condition(scope)
    return scope if filter_params[:year_groups].blank?

    scope.where(year_group: filter_params[:year_groups])
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def order_condition(scope)
    scope.order_by_subject_school_name
  end
end

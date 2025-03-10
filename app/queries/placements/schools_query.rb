class Placements::SchoolsQuery < ApplicationQuery
  MAX_LOCATION_DISTANCE = 50

  def call
    scope = Placements::School.joins(:hosting_interests, :academic_years, :placements, :mentors)

    scope = search_by_name_condition(scope)
    scope = subject_condition(scope)
    scope = itt_statuses_condition(scope)
    scope = phase_condition(scope)
    scope = last_offered_placements_condition(scope)
    scope = trained_mentors_condition(scope)
    order_condition(scope)
  end

  private

  def search_by_name_condition(scope)
    return scope if filter_params[:search_by_name].blank?

    scope.where("schools.name ILIKE ?", "%#{filter_params[:search_by_name]}%")
         .or(scope.where("urn ILIKE ?", "%#{filter_params[:search_by_name]}%"))
  end

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.where(placements: { subject_id: filter_params[:subject_ids] })
    # .or(scope.where(placements: { additional_subjects: { id: filter_params[:subject_ids] } })) TODO: Investigate why joins doesn't work for additional subjects
  end

  def itt_statuses_condition(scope)
    return scope if filter_params[:itt_statuses].blank?

    scope.where(hosting_interests: { appetite: filter_params[:itt_statuses] })
  end

  def phase_condition(scope)
    return scope if filter_params[:phases].blank?

    scope.where(phase: filter_params[:phases])
  end

  def last_offered_placements_condition(scope)
    return scope if filter_params[:last_offered_placements_academic_year_ids].blank?

    if filter_params[:last_offered_placements_academic_year_ids].include?("never_offered")
      scope.where.not(academic_years: { starts_on: ..Placements::AcademicYear.current.starts_on })
    else
      scope.where(academic_years: filter_params[:last_offered_placements_academic_year_ids])
    end
  end

  def trained_mentors_condition(scope)
    return scope if filter_params[:trained_mentors].blank?

    scope.where(mentors: { trained: filter_params[:trained_mentors] })
  end

  def filter_params
    @filter_params ||= params.fetch(:filters, {})
  end

  def school_ids_near_location(location_coordinates)
    School.near(
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

      scope.where(id: school_ids).order(:name)
    else
      scope.order(:name)
    end
  end
end

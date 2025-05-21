class Placements::SchoolsQuery < ApplicationQuery
  MAX_LOCATION_DISTANCE = 50

  def initialize(academic_year:, params: {})
    @academic_year = academic_year
    super(params:)
  end

  def call
    scope = School.left_outer_joins(:hosting_interests, :academic_years, :placements, :mentors)

    scope = search_by_name_condition(scope)
    scope = schools_i_work_with_condition(scope)
    scope = subject_condition(scope)
    scope = phase_condition(scope)
    scope = last_offered_placements_condition(scope)
    scope = year_group_condition(scope)
    scope = itt_statuses_condition(scope)
    order_condition(scope)
  end

  private

  attr_reader :academic_year

  def schools_i_work_with_condition(scope)
    return scope if filter_params[:schools_i_work_with_ids].blank?

    scope.where(id: filter_params[:schools_i_work_with_ids])
  end

  def search_by_name_condition(scope)
    return scope if filter_params[:search_by_name].blank?

    scope.where("schools.name ILIKE ?", "%#{filter_params[:search_by_name]}%")
         .or(scope.where("urn ILIKE ?", "%#{filter_params[:search_by_name]}%"))
  end

  def subject_condition(scope)
    return scope if filter_params[:subject_ids].blank?

    scope.left_outer_joins(placements: :additional_subjects)
         .where(placements: { subject_id: filter_params[:subject_ids] })
         .or(
           scope.left_outer_joins(placements: :additional_subjects)
                .where(additional_subjects: { id: filter_params[:subject_ids] }),
         )
  end

  def year_group_condition(scope)
    return scope if filter_params[:year_groups].blank?

    scope.where(placements: { year_group: filter_params[:year_groups] })
  end

  def itt_statuses_condition(scope)
    hosting_interests = filter_params[:itt_statuses]
    return scope if hosting_interests.blank?

    conditions = []

    if hosting_interests.include?("open")
      conditions << scope.where(hosting_interests: { appetite: "interested" })
    end

    if hosting_interests.include?("not_open")
      conditions << scope.where(hosting_interests: { appetite: "not_open" })
    end

    if hosting_interests.include?("unfilled_placements")
      conditions << scope.where(hosting_interests: { appetite: "actively_looking" }, placements: { academic_year_id: academic_year.id, provider: nil })
    end

    if hosting_interests.include?("filled_placements")
      conditions << scope.where(hosting_interests: { appetite: "actively_looking" }, placements: { academic_year_id: academic_year.id }).excluding(scope.where(placements: { provider: nil }))
    end

    conditions.reduce(scope.none) { |combined_scope, condition| combined_scope.or(condition) }
  end

  def phase_condition(scope)
    return scope if filter_params[:phases].blank?

    scope.where(phase: filter_params[:phases])
  end

  def last_offered_placements_condition(scope)
    return scope if filter_params[:last_offered_placements_academic_year_ids].blank?

    if filter_params[:last_offered_placements_academic_year_ids].include?("never_offered")
      scope.where.missing(:academic_years)
           .or(
             scope.where(
               academic_years: filter_params[:last_offered_placements_academic_year_ids] - %w[never_offered],
             ),
           )
    else
      scope.where(academic_years: filter_params[:last_offered_placements_academic_year_ids])
    end
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

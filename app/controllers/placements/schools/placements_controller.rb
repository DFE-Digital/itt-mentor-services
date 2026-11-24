class Placements::Schools::PlacementsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show remove destroy preview]
  before_action :set_decorated_placement, only: %i[show remove preview]

  def index
    @hosting_interest = @school.current_hosting_interest(
      academic_year: current_user.selected_academic_year,
    )
    return if @hosting_interest&.interested? || @hosting_interest&.not_open?

    @pagy, @placements = pagy(
      placements
        .where(academic_year: academic_year_scope)
        .includes(:subject, :mentors, :additional_subjects, :provider)
        .order("subjects.name"),
    )
    @placements = @placements.decorate
  end

  def show; end

  def remove
    if policy(@placement).destroy?
      render "confirm_remove"
    else
      render "can_not_remove"
    end
  end

  def destroy
    authorize @placement

    if @school.last_placement_for_school?(placement: @placement)
      @school.current_hosting_interest(academic_year: academic_year_scope)&.destroy!
      @placement.destroy!
      redirect_to index_path, flash: {
        heading: t(".placement_deleted"),
        body: t(".last_placement_deleted_body"),
      }
    else
      @placement.destroy!
      redirect_to index_path, flash: {
        heading: t(".placement_deleted"),
      }
    end
  end

  def preview; end

  private

  def placements
    policy_scope(@school.placements)
  end

  def current_academic_year
    @current_academic_year ||= Placements::AcademicYear.current
  end

  def academic_year_scope
    current_user.selected_academic_year
  end

  def set_placement
    @placement = placements.find(params.require(:id))
  end

  def set_decorated_placement
    @placement = @placement.decorate
  end

  def index_path
    placements_school_placements_path(@school)
  end
end

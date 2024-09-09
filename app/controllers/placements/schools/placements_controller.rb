class Placements::Schools::PlacementsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show remove destroy preview]
  before_action :set_decorated_placement, only: %i[show remove preview]
  before_action :current_academic_year, only: :index

  helper_method :edit_attribute_path, :add_provider_path, :add_mentor_path

  def index
    @pagy, placements = pagy(placements_scope.includes(:subject, :mentors, :additional_subjects, :provider).order("subjects.name"))
    @placements = placements.decorate
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

    @placement.destroy!
    redirect_to index_path, flash: { success: t(".placement_deleted") }
  end

  def preview; end

  private

  def placements_scope
    policy_scope(@school.placements.where(academic_year: academic_year_scope))
  end

  def current_academic_year
    @current_academic_year ||= Placements::AcademicYear.current
  end

  def academic_year_scope
    params[:year] == "next" ? current_academic_year.next : current_academic_year
  end

  def set_placement
    @placement = @school.placements.find(params.require(:id))
  end

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_decorated_placement
    @placement = @placement.decorate
  end

  def edit_attribute_path(attribute)
    new_edit_placement_placements_school_placement_path(@school, @placement, step: attribute)
  end

  def add_provider_path
    placements_school_partner_providers_path
  end

  def add_mentor_path
    placements_school_mentors_path
  end

  def index_path
    placements_school_placements_path(@school)
  end
end

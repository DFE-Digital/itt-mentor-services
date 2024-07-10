class Placements::Schools::PlacementsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show remove destroy]
  before_action :set_decorated_placement, only: %i[show remove]

  helper_method :edit_attribute_path, :add_provider_path, :add_mentor_path

  def index
    @pagy, placements = pagy(@school.placements.includes(:subject, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  def remove; end

  def destroy
    @placement.destroy!
    redirect_to placements_school_placements_path(@school), flash: { success: t(".placement_deleted") }
  end

  private

  def set_placement
    @placement = @school.placements.find(params.require(:id))
  end

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_decorated_placement
    @placement = @placement.decorate
  end

  def authorize_placement
    authorize @placement
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
end

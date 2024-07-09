class Placements::Schools::PlacementsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show update remove destroy]
  before_action :set_decorated_placement, only: %i[show remove]

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
end

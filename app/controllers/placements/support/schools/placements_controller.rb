class Placements::Support::Schools::PlacementsController < Placements::Support::ApplicationController
  before_action :set_school
  before_action :set_placement, except: %i[index]

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  def remove; end

  def destroy
    @placement.destroy!
    redirect_to placements_support_school_placements_path(@school), flash: { success: t(".placement_removed") }
  end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_placement
    @placement = @school.placements.find(params.fetch(:id)).decorate
  end
end

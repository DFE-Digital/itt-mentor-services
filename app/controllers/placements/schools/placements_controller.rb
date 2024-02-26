class Placements::Schools::PlacementsController < ApplicationController
  before_action :set_school
  before_action :set_placement, only: [:show]

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show; end

  private

  def set_placement
    @placement = @school.placements.find(params.require(:id)).decorate
  end

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end
end

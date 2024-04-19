class Placements::Support::Schools::PlacementsController < Placements::Support::ApplicationController
  before_action :set_school
  before_action :set_placement, only: %i[show]

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  def show
    @placement = @school.placements.find(params.fetch(:id)).decorate
  end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_placement
    @placement = @school.placements.find(params.fetch(:id))
  end
end

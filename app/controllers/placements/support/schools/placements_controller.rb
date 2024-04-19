class Placements::Support::Schools::PlacementsController < Placements::Support::ApplicationController
  before_action :set_school

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end
end

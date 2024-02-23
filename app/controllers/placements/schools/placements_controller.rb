class Placements::Schools::PlacementsController < ApplicationController
  before_action :set_school

  def index
    @pagy, placements = pagy(@school.placements.includes(:subjects, :mentors).order("subjects.name"))
    @placements = placements.decorate
  end

  private

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end
end

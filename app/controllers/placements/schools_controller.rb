class Placements::SchoolsController < Placements::ApplicationController
  def show
    @school = schools.find(params.require(:id)).decorate
  end

  private

  def schools
    current_user.support_user? ? Placements::School.all : current_user.schools
  end
end

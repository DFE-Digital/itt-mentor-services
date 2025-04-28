class Placements::SchoolsController < Placements::ApplicationController
  def show
    @school = schools.find(params.require(:id)).decorate
    @selected_academic_year = current_user.selected_academic_year
  end

  private

  def schools
    policy_scope(Placements::School)
  end
end

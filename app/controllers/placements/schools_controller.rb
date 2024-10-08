class Placements::SchoolsController < Placements::ApplicationController
  def show
    @school = schools.find(params.require(:id)).decorate
  end

  private

  def schools
    policy_scope(Placements::School)
  end
end

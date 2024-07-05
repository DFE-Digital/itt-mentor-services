class Placements::Support::SchoolsController < Placements::ApplicationController
  def show
    @school = Placements::School.find(params[:id]).decorate
  end
end

class Placements::SchoolsController < ApplicationController
  def show
    @school = current_user.schools.find(params.require(:id))&.decorate
  end
end

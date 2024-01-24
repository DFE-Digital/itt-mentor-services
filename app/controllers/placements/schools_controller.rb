class Placements::SchoolsController < ApplicationController
  before_action :set_schools
  def show
    @school = @schools.find(params.require(:id))&.decorate
  end

  private

  def set_schools
    @schools = current_user.schools.where(placements_service: true)
  end
end

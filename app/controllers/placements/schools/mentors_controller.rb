class Placements::Schools::MentorsController < ApplicationController
  before_action :set_school
  before_action :set_mentor, only: [:show]

  def show; end

  private

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end
end

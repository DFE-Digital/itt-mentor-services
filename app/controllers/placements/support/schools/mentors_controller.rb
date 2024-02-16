class Placements::Support::Schools::MentorsController < Placements::Support::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: [:show]

  def show; end

  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.fetch(:id))
  end
end

class Placements::Schools::MentorsController < ApplicationController
  before_action :set_school
  before_action :set_mentor, only: %i[show remove destroy]

  def index
    @pagy, @mentors = pagy(@school.mentors.order(:first_name, :last_name))
  end

  def show; end

  def remove; end

  def destroy
    mentor_membership = @mentor.mentor_memberships.find_by(school: @school)
    mentor_membership.destroy!

    redirect_to placements_school_mentors_path(@school)
    flash[:success] = t(".mentor_removed")
  end

  private

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end
end

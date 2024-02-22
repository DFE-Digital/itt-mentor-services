class Claims::Schools::MentorsController < ApplicationController
  include Claims::BelongsToSchool
  before_action :set_mentor, only: %i[show remove destroy]

  def index
    @pagy, @mentors = pagy(@school.mentors.order(:first_name, :last_name))
  end

  def show; end

  def remove; end

  def destroy
    mentor_membership = @mentor.mentor_memberships.find_by!(school: @school)
    mentor_membership.destroy!

    redirect_to claims_school_mentors_path(@school), flash: { success: t(".success") }
  end

  private

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end
end

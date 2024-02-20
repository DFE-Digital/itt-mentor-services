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

  def new
    mentor_form
  end

  def check
    render :new unless mentor_form.valid?
  rescue TeachingRecord::RestClient::TeacherNotFoundError
    render :no_results
  end

  def create
    mentor_form.save!

    redirect_to placements_school_mentors_path(@school), flash: { success: t(".mentor_added") }
  end

  private

  def mentor_params
    params.require(:mentor_form)
          .permit(:first_name, :last_name, :trn)
          .merge(default_params)
  end

  def default_params
    { service: :placements, school: @school }
  end

  def mentor_form
    @mentor_form ||=
      if params[:mentor_form].present?
        MentorForm.new(mentor_params)
      else
        MentorForm.new(default_params)
      end
  end

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end
end

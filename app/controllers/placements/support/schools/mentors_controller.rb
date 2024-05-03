class Placements::Support::Schools::MentorsController < Placements::Support::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: %i[show remove destroy]

  def index
    @pagy, @mentors = pagy(@school.mentors.order_by_full_name)
  end

  def show; end

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

    redirect_to placements_support_school_mentors_path(@school), flash: { success: t(".mentor_added") }
  end

  def remove; end

  def destroy
    mentor_membership = @mentor.mentor_memberships.find_by(school: @school)
    mentor_membership.destroy!

    redirect_to placements_support_school_mentors_path(@school)
    flash[:success] = t(".mentor_removed")
  end

  private

  def mentor_params
    params.require(:placements_mentor_form)
          .permit(:first_name, :last_name, :trn, :date_of_birth)
          .merge(default_params)
  end

  def default_params
    { school: @school }
  end

  def mentor_form
    @mentor_form ||=
      if params[:placements_mentor_form].present?
        Placements::MentorForm.new(mentor_params)
      else
        Placements::MentorForm.new(default_params)
      end
  end

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.fetch(:id))
  end
end

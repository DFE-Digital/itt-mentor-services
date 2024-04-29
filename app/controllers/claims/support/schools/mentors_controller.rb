class Claims::Support::Schools::MentorsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_mentor, only: %i[show remove destroy]
  before_action :authorize_mentor

  helper_method :mentor_form

  def index
    @pagy, @mentors = pagy(@school.mentors.order(:first_name, :last_name))
  end

  def new; end

  def create
    mentor_form.save!

    redirect_to claims_support_school_mentors_path(@school), flash: { success: t(".success") }
  end

  def check
    render :new unless mentor_form.valid?
  rescue TeachingRecord::RestClient::TeacherNotFoundError
    render :no_results
  end

  def show; end

  def remove; end

  def destroy
    mentor_membership = @mentor.mentor_memberships.find_by!(school: @school)
    mentor_membership.destroy!

    redirect_to claims_support_school_mentors_path(@school), flash: { success: t(".success") }
  end

  private

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end

  def authorize_mentor
    authorize @mentor || Claims::Mentor
  end

  def default_params
    { school: @school }
  end

  def mentor_params
    params.require(:claims_mentor_form)
          .permit(:first_name, :last_name, :trn, :date_of_birth)
          .merge(default_params)
  end

  def mentor_form
    @mentor_form ||=
      if params[:claims_mentor_form].present?
        Claims::MentorForm.new(mentor_params)
      else
        Claims::MentorForm.new(default_params)
      end
  end
end

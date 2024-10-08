class Claims::Schools::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_mentor, only: %i[show remove destroy]
  before_action :set_mentor_membership, only: %i[remove destroy]

  before_action :authorize_mentor
  before_action :authorize_mentor_membership, only: %i[remove destroy]

  helper_method :mentor_form

  def index
    @pagy, @mentors = pagy(@school.mentors.order_by_full_name)
  end

  def show; end

  def remove; end

  def new; end

  def create
    mentor_form.save!

    redirect_to claims_school_mentors_path(@school), flash: {
      heading: t(".success"),
    }
  end

  def check
    render :new unless mentor_form.valid?
  rescue TeachingRecord::RestClient::TeacherNotFoundError
    render :no_results
  end

  def destroy
    @mentor_membership.destroy!

    redirect_to claims_school_mentors_path(@school), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end

  def set_mentor_membership
    @mentor_membership = @mentor.mentor_memberships.find_by!(school: @school)
  end

  def authorize_mentor
    authorize @mentor || Claims::Mentor
  end

  def authorize_mentor_membership
    authorize @mentor_membership
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

class Placements::Schools::MentorsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: %i[show remove destroy]
  before_action :set_mentor_membership, only: %i[remove destroy]

  def index
    @pagy, @mentors = pagy(@school.mentors.order_by_full_name)
  end

  def show; end

  def remove
    if policy(@mentor_membership).destroy?
      render "confirm_remove"
    else
      render "can_not_remove"
    end
  end

  def destroy
    authorize @mentor_membership
    @mentor_membership.destroy!

    flash[:success] = t(".mentor_removed")
    redirect_to_index_path
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
    flash[:success] = t(".mentor_added")

    redirect_to_index_path
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
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.require(:id))
  end

  def set_mentor_membership
    @mentor_membership = @mentor.mentor_memberships.find_by(school: @school)
  end

  def redirect_to_index_path
    redirect_to placements_school_mentors_path(@school)
  end
end

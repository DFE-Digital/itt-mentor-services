class Claims::Schools::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_mentor, only: %i[show remove destroy]
  before_action :set_mentor_membership, only: %i[remove destroy]

  before_action :authorize_mentor
  before_action :authorize_mentor_membership, only: %i[remove destroy]

  def index
    @pagy, @mentors = pagy(@school.mentors.order_by_full_name)
  end

  def show; end

  def remove; end

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
end

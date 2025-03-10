class Placements::Schools::MentorsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: %i[show remove destroy]
  before_action :set_mentor_membership, only: %i[remove destroy]

  def index
    @pagy, @mentors = pagy(mentors.order_by_full_name)
  end

  def show; end

  def remove
    @mentor = @mentor.decorate

    if policy(@mentor_membership).destroy?
      render "confirm_remove"
    else
      render "can_not_remove"
    end
  end

  def destroy
    authorize @mentor_membership
    @mentor_membership.destroy!

    flash[:heading] = t(".mentor_deleted")
    redirect_to_index_path
  end

  private

  def mentors
    policy_scope(@school.mentors)
  end

  def set_mentor
    @mentor = mentors.find(params.require(:id))
  end

  def set_mentor_membership
    @mentor_membership = @mentor.mentor_memberships.find_by(school: @school)
  end

  def redirect_to_index_path
    redirect_to placements_school_mentors_path(@school)
  end
end

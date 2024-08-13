class Placements::Schools::MentorsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: %i[show remove destroy]
  before_action :set_mentor_membership, only: %i[remove destroy]

  def index
    scope = policy_scope(@school.mentors)
    @pagy, @mentors = pagy(scope.order_by_full_name)
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

  private

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

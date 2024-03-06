class Claims::Support::Schools::Claims::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool
  before_action :authorize_claim

  helper_method :claim_mentors_form

  def new; end

  def create
    if claim_mentors_form.save
      redirect_to(
        edit_claims_support_school_claim_mentor_training_path(
          @school,
          claim,
          claim.mentor_trainings.without_hours.first,
        ),
      )
    else
      render :new
    end
  end

  def edit; end

  def update
    if claim_mentors_form.save
      path = if claim.mentor_trainings.without_hours.any?
               edit_claims_support_school_claim_mentor_training_path(
                 claim.school,
                 claim,
                 claim.mentor_trainings.without_hours.first,
               )
             else
               check_claims_support_school_claim_path(claim.school, claim)
             end

      redirect_to path
    else
      render :edit
    end
  end

  private

  def claim_params
    params.require(:claim).permit(mentor_ids: [])
  end

  def claim
    @claim ||= @school.claims.find(params.require(:claim_id))
  end

  def claim_mentors_form
    @claim_mentors_form ||=
      if params[:claim].present?
        Claim::MentorsForm.new(claim:, mentor_ids: claim_params[:mentor_ids])
      else
        Claim::MentorsForm.new(claim:)
      end
  end

  def authorize_claim
    authorize claim
  end
end

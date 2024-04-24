class Claims::Schools::Claims::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool
  before_action :authorize_claim

  helper_method :claim_mentors_form

  def new; end

  def create
    if claim_mentors_form.save
      redirect_to(
        edit_claims_school_claim_mentor_training_path(
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
      redirect_to claim_mentors_form.update_success_path
    else
      render :edit
    end
  end

  private

  def claim_params
    params.require(:claims_claim_mentors_form).permit(mentor_ids: [])
  end

  def claim
    @claim ||= @school.claims.find(params.require(:claim_id))
  end

  def claim_mentors_form
    @claim_mentors_form ||=
      if params[:claims_claim_mentors_form].present?
        Claims::Claim::MentorsForm.new(claim:, mentor_ids: claim_params[:mentor_ids])
      else
        Claims::Claim::MentorsForm.new(claim:)
      end
  end

  def authorize_claim
    authorize claim
  end
end

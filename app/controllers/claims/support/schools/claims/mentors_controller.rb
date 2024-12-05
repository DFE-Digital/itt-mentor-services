class Claims::Support::Schools::Claims::MentorsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :authorize_claim
  helper_method :claim_mentors_form

  def new; end

  def create
    if claim_mentors_form.save
      if claim.mentor_trainings.without_hours.any?
        redirect_to(
          edit_claims_support_school_claim_mentor_training_path(
            @school,
            claim,
            claim.mentor_trainings.without_hours.first,
          ),
        )
      else
        redirect_to check_claims_support_school_claim_path(@school, claim)
      end
    else
      render :new
    end
  end

  def create_revision
    revision = Claims::Claim::CreateRevision.call(claim: @claim)
    redirect_to edit_claims_support_school_claim_mentors_path(@school, revision)
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
    params.require(:claims_support_claim_mentors_form).permit(mentor_ids: [])
  end

  def claim
    @claim ||= @school.claims.find(params.require(:claim_id))
  end

  def claim_mentors_form
    @claim_mentors_form ||=
      if params[:claims_support_claim_mentors_form].present?
        Claims::Support::Claim::MentorsForm.new(claim:, mentor_ids: claim_params[:mentor_ids])
      else
        Claims::Support::Claim::MentorsForm.new(claim:)
      end
  end

  def authorize_claim
    authorize claim
  end
end

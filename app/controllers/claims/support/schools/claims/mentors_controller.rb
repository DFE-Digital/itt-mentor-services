class Claims::Support::Schools::Claims::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool
  before_action :authorize_claim

  def new
    render locals: { claim_mentors_form: }
  end

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
      render :new, locals: { claim_mentors_form: }
    end
  end

  def edit
    if create_revision?
      revision = claim.create_revision!

      render locals: { claim_mentors_form: claim_mentors_form(revision) }
    else
      render locals: { claim_mentors_form: }
    end
  end

  def update
    if claim_mentors_form.save
      redirect_to claim_mentors_form.update_success_path
    else
      render :edit, locals: { claim_mentors_form: }
    end
  end

  private

  def claim_params
    params.require(:claims_claim).permit(mentor_ids: [])
  end

  def claim
    @claim ||= @school.claims.find(params.require(:claim_id))
  end

  def claim_mentors_form(claim_revision = nil)
    claim_param = claim_revision || claim

    @claim_mentors_form ||=
      if params[:claims_claim].present?
        Claims::Support::Claim::MentorsForm.new(
          claim: claim_param,
          mentor_ids: claim_params[:mentor_ids],
        )
      else
        Claims::Support::Claim::MentorsForm.new(claim: claim_param)
      end
  end

  def authorize_claim
    authorize claim
  end

  def create_revision?
    params[:revision] == "true"
  end
end

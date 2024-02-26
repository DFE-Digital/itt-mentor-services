class Claims::Schools::Claims::MentorsController < Claims::ApplicationController
  include Claims::BelongsToSchool
  before_action :authorize_claim

  helper_method :claim_mentors_form

  def new; end

  def create
    if claim_mentors_form.save
      redirect_to check_claims_school_claim_path(@school, claim)
    else
      render :new
    end
  end

  def edit; end

  def update
    if claim_mentors_form.save
      redirect_to check_claims_school_claim_path(@school, claim)
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
    authorize @claim || Claim
  end
end

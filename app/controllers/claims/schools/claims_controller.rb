class Claims::Schools::ClaimsController < ApplicationController
  include Claims::BelongsToSchool

  def index
    @pagy, @claims = pagy(@school.claims.where(draft: false))
  end

  def new
    claim = @school.claims.create!(draft: true)
    redirect_to claims_school_claim_path(id: claim.id)
  end

  def show
    @claim = claim
  end

  def edit
    render locals: { claim:, mentor_trainings:, school: @school, step: }
  end

  def update
    claim_form = ClaimForm.new(claim:, step:, claim_params:)

    if claim_form.save
      redirect_to claims_school_claim_path(id: claim.id)
      flash[:success] = t(".claim_updated")
    else
      render :edit, locals: { claim:, mentor_trainings:, school: @school, step: }
    end
  end

  private

  def mentor_trainings
    claim.mentor_trainings.build if claim.mentor_trainings.blank?
  end

  def claim_params
    params.require(:claim).permit(
      :provider_id,
      mentor_trainings_attributes: %i[provider_id mentor_id id],
    )
  end

  def claim
    @claim ||= @school.claims.find(params.require(:id)).decorate
  end

  def step
    params.require(:step)
  end
end

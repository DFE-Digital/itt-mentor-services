class Claims::Schools::ClaimsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_claim, only: %i[show edit update]
  before_action :authorize_claim

  def index
    @pagy, @claims = pagy(@school.claims.where(draft: false))
  end

  def new
    claim = @school.claims.create!(draft: true)
    redirect_to claims_school_claim_path(id: claim.id)
  end

  def show; end

  def edit
    render locals: { claim: @claim, mentor_trainings:, school: @school, step: }
  end

  def update
    claim_form = ClaimForm.new(claim: @claim, step:, claim_params:)

    if claim_form.save
      redirect_to claims_school_claim_path(id: @claim.id)
      flash[:success] = t(".claim_updated")
    else
      render :edit, locals: { claim: @claim, mentor_trainings:, school: @school, step: }
    end
  end

  private

  def mentor_trainings
    @claim.mentor_trainings.build if @claim.mentor_trainings.blank?
  end

  def claim_params
    params.require(:claim).permit(
      :provider_id,
      mentor_trainings_attributes: %i[provider_id mentor_id id],
    )
  end

  def set_claim
    @claim = @school.claims.find(params.require(:id)).decorate
  end

  def step
    params.require(:step)
  end

  def authorize_claim
    authorize @claim || Claim
  end
end

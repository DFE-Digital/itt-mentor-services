class Claims::Schools::ClaimsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_claim, only: %i[show confirmation remove destroy]
  before_action :authorize_claim

  helper_method :edit_attribute_path

  def index
    @pagy, @claims = pagy(
      @school.claims.includes(:provider, :mentor_trainings).active.order_created_at_desc
    )
  end

  def show; end

  def confirmation; end

  def rejected; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_school_claims_path(@school, @claim), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_claim
    @claim = @school.claims.find(claim_id)
  end

  def claim_id
    params[:claim_id] || params[:id]
  end

  def authorize_claim
    authorize @claim || Claims::Claim.new(school: @school)
  end

  def edit_attribute_path(attribute)
    new_edit_claim_claims_school_claim_path(@school, @claim, step: attribute)
  end
end

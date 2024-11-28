class Claims::Support::Schools::ClaimsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_claim, only: %i[show remove destroy]
  before_action :authorize_claim

  helper_method :edit_attribute_path

  def index
    @pagy, @claims = pagy(@school.claims.active.order_created_at_desc)
  end

  def show; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_support_school_claims_path(@school, @claim), flash: {
      heading: t(".success"),
    }
  end

  def rejected; end

  private

  def claim_id
    params[:claim_id] || params[:id]
  end

  def set_claim
    @claim = @school.claims.find(claim_id)
  end

  def authorize_claim
    authorize @claim || Claims::Claim.new
  end

  def edit_attribute_path(attribute)
    new_edit_claim_claims_support_school_claim_path(@school, @claim, step: attribute)
  end
end

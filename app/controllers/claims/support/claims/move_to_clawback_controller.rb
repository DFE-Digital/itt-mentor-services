class Claims::Support::Claims::MoveToClawbackController < Claims::Support::ApplicationController
  before_action :set_claim
  before_action :authorize_claim

  def create
    Claims::Claim::Clawback::MoveToClawback.call(claim: @claim, current_user:)

    redirect_to claims_support_claims_clawback_path(@claim), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:claim_id))
  end

  def authorize_claim
    authorize @claim, :move_to_clawback?
  end
end

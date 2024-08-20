class Claims::Support::Claims::Payments::ClaimsController < Claims::Support::ApplicationController
  before_action :set_claim
  before_action :authorize_claim

  def information_sent
    @claim.update!(status: :payment_information_sent)

    redirect_to claims_support_claim_path(@claim), flash: { heading: t(".success"), success: true }
  end

  def reject
    @claim.update!(status: :payment_not_approved)

    redirect_to claims_support_claim_path(@claim), flash: { heading: t(".success"), success: true }
  end

  private

  def set_claim
    @claim = policy_scope(Claims::Claim, policy_scope_class: Claims::Support::Payments::ClaimPolicy::Scope).find(params[:id])
  end

  def authorize_claim
    authorize @claim, policy_class: Claims::Support::Payments::ClaimPolicy
  end
end

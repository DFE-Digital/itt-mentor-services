class Claims::Support::Claims::Payments::ClaimsController < Claims::Support::ApplicationController
  append_pundit_namespace :claims, :payments

  before_action :set_claim, only: %i[show confirm_information_sent information_sent confirm_paid paid confirm_reject reject]
  before_action :authorize_claim

  def show; end
  def confirm_information_sent; end

  def information_sent
    @claim.payment_information_sent!

    redirect_to claims_support_claims_payments_claim_path(@claim), flash: { success: true, heading: t(".success") }
  end

  def confirm_paid; end

  def paid
    @claim.paid!

    redirect_to claims_support_claims_payments_claim_path(@claim), flash: { success: true, heading: t(".success") }
  end

  def confirm_reject; end

  def reject
    @claim.payment_not_approved!

    redirect_to claims_support_claims_payments_claim_path(@claim), flash: { success: true, heading: t(".success") }
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end
end

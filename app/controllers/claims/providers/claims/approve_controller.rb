class Claims::Providers::Claims::ApproveController < Claims::Providers::ApplicationController
  before_action :set_provider
  before_action :set_claim
  before_action :authorize_claim

  def new; end

  def create
    Claims::Claim::Sampling::Paid.call(claim: @claim)

    redirect_to claims_provider_claims_path(@provider), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_claim
    @claim = provider_claims.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim, :approve?
  end

  def provider_claims
    @provider_claims ||= policy_scope(Claims::Claim.where(provider: @provider))
      .includes(:school, :provider, :claim_window, mentor_trainings: :mentor)
      .not_draft_status
      .provider_visible
  end
end

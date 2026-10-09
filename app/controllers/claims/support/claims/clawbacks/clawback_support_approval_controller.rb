class Claims::Support::Claims::Clawbacks::ClawbackSupportApprovalController < Claims::Support::ApplicationController
  before_action :set_claim
  before_action :authorize_claim

  def new
    @mentor_trainings = @claim.mentor_trainings.includes(:mentor).not_assured.order_by_mentor_full_name
  end

  def create
    Claims::Claim::Clawback::Approve.call(claim: @claim, current_user:)

    redirect_to claims_support_claims_clawback_path(@claim), flash: {
      heading: t(".approved.heading"),
      body: t(".approved.body"),
    }
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params[:id])
  end

  def authorize_claim
    authorize @claim, :approve_clawback?
  end
end

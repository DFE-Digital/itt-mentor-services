class Claims::Support::Claims::ClawbacksController < Claims::ApplicationController
  before_action :skip_authorization
  before_action :set_claims

  def show; end

  def create
    redirect_to claims_support_claims_clawback_path
  end

  private

  def set_claims
    @claims = Claims::Claim.none
  end
end

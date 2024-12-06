class Claims::Support::Claims::Payments::ClaimsController < Claims::Support::ApplicationController
  before_action :set_claim, only: %i[show]
  before_action :authorize_claim

  def show; end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def authorize_claim
    authorize [:payments, @claim || Claims::Claim]
  end
end

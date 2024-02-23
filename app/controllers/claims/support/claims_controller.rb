class Claims::Support::ClaimsController < Claims::Support::ApplicationController
  before_action :set_claim, only: %i[show]
  before_action :authorize_claim

  def index
    @pagy, @claims = pagy(Claim.all.order(created_at: :desc))
  end

  def show; end

  private

  def set_claim
    @claim = Claim.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim || Claim
  end
end

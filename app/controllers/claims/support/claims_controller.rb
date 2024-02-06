class Claims::Support::ClaimsController < Claims::Support::ApplicationController
  def index
    @pagy, @claims = pagy(Claim.all.order(created_at: :desc))
  end

  def show
    @claim = Claim.find(params.require(:id))
  end
end

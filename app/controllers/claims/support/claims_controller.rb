class Claims::Support::ClaimsController < Claims::Support::ApplicationController
  before_action :set_claim, only: %i[show]
  before_action :authorize_claim

  def index
    @pagy, @claims = pagy(Claims::Claim.visible.order_created_at_desc)
  end

  def show; end

  def download_csv
    csv_data = Claims::GenerateClaimsCsv.call

    send_data csv_data, filename: "claims-#{Date.current}.csv", type: "text/csv", disposition: "attachment"
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end
end

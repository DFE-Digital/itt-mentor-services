class Claims::Providers::ClaimsDownloadsController < Claims::Providers::ApplicationController
  before_action :set_provider
  before_action :authorize_download

  def show
    csv_data = Claims::Claim::GenerateProviderCSV.call(
      claims: policy_scope(Claims::Claim.where(provider: @provider)).not_draft_status,
    )

    send_data csv_data,
              filename: "claims_funding_for_mentor_training_claims_#{Date.current.iso8601}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  private

  def authorize_download
    authorize Claims::Claim, :download?
  end
end

class Claims::Sampling::UpdateClaimWithProviderResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    if claim_update_details.fetch(:status) == :paid
      Claims::Claim::Sampling::Paid.call(claim: claim(claim_update_details.fetch(:id)))
    else
      Claims::Claim::Sampling::ProviderNotApproved.call(
        claim: claim(claim_update_details.fetch(:id)),
        provider_responses: claim_update_details.fetch(:provider_responses),
      )
    end
  end

  private

  def claim(id)
    Claims::Claim.sampling_in_progress.find_by!(id:)
  end
end

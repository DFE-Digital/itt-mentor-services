class Claims::Clawback::UpdateClaimWithESFAResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    Claims::Claim::Clawback::Complete.call(
      claim: claim(claim_update_details.fetch(:id)),
      esfa_responses: claim_update_details.fetch(:esfa_responses),
    )
  end

  private

  def claim(id)
    Claims::Claim.clawback_in_progress.find(id)
  end
end

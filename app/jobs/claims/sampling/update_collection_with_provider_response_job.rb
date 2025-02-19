class Claims::Sampling::UpdateCollectionWithProviderResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    sampled_claims(claim_update_details.pluck(:id)).find_in_batches do |batch|
      batch.each do |claim|
        updated_details_for_claim = claim_update_details.find { |details| details[:id] == claim.id }
        Claims::Sampling::UpdateClaimWithProviderResponseJob.perform_later(updated_details_for_claim)
      end
    end
  end

  private

  def sampled_claims(ids)
    Claims::Claim.sampling_in_progress.where(id: ids)
  end
end

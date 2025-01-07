class Claims::Clawback::UpdateCollectionWithESFAResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    clawback_in_progress_claims(claim_update_details.pluck(:id)).find_in_batches do |batch|
      batch.each do |claim|
        updated_details_for_claim = claim_update_details.find { |details| details[:id] == claim.id }
        Claims::Clawback::UpdateClaimWithESFAResponseJob.perform_later(updated_details_for_claim)
      end
    end
  end

  private

  def clawback_in_progress_claims(ids)
    Claims::Claim.clawback_in_progress.where(id: ids)
  end
end

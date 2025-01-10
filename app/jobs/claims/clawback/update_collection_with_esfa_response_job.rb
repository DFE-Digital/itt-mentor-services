class Claims::Clawback::UpdateCollectionWithESFAResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_ids)
    clawback_in_progress_claims(claim_ids).find_in_batches do |batch|
      batch.each do |claim|
        Claims::Clawback::UpdateClaimWithESFAResponseJob.perform_later(claim)
      end
    end
  end

  private

  def clawback_in_progress_claims(ids)
    Claims::Claim.clawback_in_progress.where(id: ids)
  end
end

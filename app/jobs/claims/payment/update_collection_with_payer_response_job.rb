class Claims::Payment::UpdateCollectionWithPayerResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    payment_in_progress_claims(claim_update_details.pluck(:id)).find_in_batches do |batch|
      batch.each do |claim|
        updated_details_for_claim = claim_update_details.find { |details| details[:id] == claim.id }
        next unless %w[paid unpaid].include?(updated_details_for_claim.fetch(:status))

        Claims::Payment::UpdateClaimWithPayerResponseJob.perform_later(updated_details_for_claim)
      end
    end
  end

  private

  def payment_in_progress_claims(ids)
    Claims::Claim.payment_in_progress.where(id: ids)
  end
end

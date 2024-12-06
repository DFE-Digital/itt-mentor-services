class Claims::Sampling::FlagCollectionForSamplingJob < ApplicationJob
  queue_as :default

  def perform(claim_ids)
    paid_claims(claim_ids).find_in_batches do |batch_of_claims|
      batch_of_claims.each do |claim|
        Claims::Sampling::FlagForSamplingJob.perform_later(claim)
      end
    end
  end

  private

  def paid_claims(ids)
    Claims::Claim.paid_for_current_academic_year.where(id: ids)
  end
end

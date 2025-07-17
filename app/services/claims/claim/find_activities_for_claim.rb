class Claims::Claim::FindActivitiesForClaim < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  attr_reader :claim

  def call
    Claims::ClaimActivity.where(
      record_type: "Claims::Claim", record_id: claim.id,
    ).or(
      Claims::ClaimActivity.where(
        record_type: "Claims::Sampling",
        record_id: Claims::Sampling.joins(provider_samplings: { provider_sampling_claims: :claim })
                                    .where(claims: { id: claim.id })
                                    .select(:id),
      ),
    ).or(
      Claims::ClaimActivity.where(
        record_type: "Claims::Clawback",
        record_id: Claims::Clawback.joins(:clawback_claims)
                                    .where(clawback_claims: { claim_id: claim.id })
                                    .select(:id),
      ),
    ).or(
      Claims::ClaimActivity.where(
        record_type: "Claims::Payment",
        record_id: Claims::Payment.joins(:payment_claims)
                                  .where(payment_claims: { claim_id: claim.id })
                                  .select(:id),
      ),
    )
  end
end

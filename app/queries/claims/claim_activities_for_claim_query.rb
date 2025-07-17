class Claims::ClaimActivitiesForClaimQuery < ApplicationQuery
  def initialize(claim:, params: {})
    super(params: params)
    @claim = claim
  end

  def call
    scope = Claims::ClaimActivity.none
    scope = for_claim(scope)
    scope = for_sampling(scope)
    scope = for_clawbacks(scope)
    scope = for_payments(scope)
    scope.order(:created_at)
  end

  private

  attr_reader :claim

  def for_claim(scope)
    scope.or(Claims::ClaimActivity.where(record_type: "Claims::Claim", record_id: claim.id))
  end

  def for_sampling(scope)
    scope.or(Claims::ClaimActivity.where(record_type: "Claims::Sampling", record_id: sampling_ids))
  end

  def for_clawbacks(scope)
    scope.or(Claims::ClaimActivity.where(record_type: "Claims::Clawback", record_id: clawback_ids))
  end

  def for_payments(scope)
    scope.or(Claims::ClaimActivity.where(record_type: "Claims::Payment",  record_id: payment_ids))
  end

  def sampling_ids
    @sampling_ids ||= Claims::Sampling
      .joins(provider_samplings: { provider_sampling_claims: :claim })
      .where(claims: { id: claim.id })
      .select(:id)
  end

  def clawback_ids
    @clawback_ids ||= Claims::Clawback
      .joins(:clawback_claims)
      .where(clawback_claims: { claim_id: claim.id })
      .select(:id)
  end

  def payment_ids
    @payment_ids ||= Claims::Payment
      .joins(:payment_claims)
      .where(payment_claims: { claim_id: claim.id })
      .select(:id)
  end
end

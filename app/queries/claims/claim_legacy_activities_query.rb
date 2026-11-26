class Claims::ClaimLegacyActivitiesQuery < ApplicationQuery
  SOURCE_TYPES = %w[Claims::Payment Claims::PaymentResponse Claims::Clawback Claims::ProviderSampling].freeze

  def initialize(claim:, params: {})
    super(params:)
    @claim = claim
  end

  def call
    activities = Claims::ClaimActivitiesForClaimQuery.call(claim: @claim).except(:order)
    SOURCE_TYPES.each do |source_type|
      source_ids = Claims::ClaimStatusChange.where(claim: @claim, source_type:).select(:source_id)
      activities = activities.or(Claims::ClaimActivity.where(record_type: source_type, record_id: source_ids))
    end
    activities.order(:created_at, :id)
  end
end

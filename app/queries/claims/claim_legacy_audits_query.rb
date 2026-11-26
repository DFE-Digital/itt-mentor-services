class Claims::ClaimLegacyAuditsQuery < ApplicationQuery
  def initialize(claim:, params: {})
    super(params:)
    @claim = claim
  end

  def call
    @claim.own_and_associated_audits.reorder(:created_at, :id)
  end
end

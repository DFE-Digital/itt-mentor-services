class Claims::ClaimStatusChangesQuery < ApplicationQuery
  def initialize(claim:, params: {})
    super(params:)
    @claim = claim
  end

  def call
    Claims::ClaimStatusChange.where(claim: @claim).includes(:actor, :source).chronological
  end
end

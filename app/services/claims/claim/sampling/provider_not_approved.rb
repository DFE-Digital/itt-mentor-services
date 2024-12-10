class Claims::Claim::Sampling::ProviderNotApproved < ApplicationService
  def initialize(claim:, not_assured_reason:)
    @claim = claim
    @not_assured_reason = not_assured_reason
  end

  def call
    claim.update!(
      status: :sampling_provider_not_approved,
      # not_assured_reason:,
    )
  end

  private

  attr_reader :claim, :not_assured_reason
end

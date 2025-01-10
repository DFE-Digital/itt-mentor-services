class Claims::Claim::Sampling::InProgress < ApplicationService
  def initialize(claim:, sampling_reason:)
    @claim = claim
    @sampling_reason = sampling_reason
  end

  def call
    claim.update!(status: :sampling_in_progress, sampling_reason:)
  end

  private

  attr_reader :claim, :sampling_reason
end

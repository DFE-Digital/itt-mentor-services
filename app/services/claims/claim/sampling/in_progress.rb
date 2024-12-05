class Claims::Claim::Sampling::InProgress < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.update!(status: :sampling_in_progress)
  end

  private

  attr_reader :claim
end

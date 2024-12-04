class Claims::Claim::Sampling::NotApproved < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.update!(status: :sampling_not_approved)
  end

  private

  attr_reader :claim
end

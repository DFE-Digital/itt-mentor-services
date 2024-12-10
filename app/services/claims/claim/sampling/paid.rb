class Claims::Claim::Sampling::Paid < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.update!(status: :paid)
  end

  private

  attr_reader :claim
end

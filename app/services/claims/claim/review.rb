class Claims::Claim::Review < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.update!(reviewed: true)
  end

  private

  attr_reader :claim
end

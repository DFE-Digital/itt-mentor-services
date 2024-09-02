class Claims::Claim::CalculateAmount < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  attr_reader :claim

  def call
    region = claim.school.region
    claims_funding_available_per_hour_pence = region.claims_funding_available_per_hour_pence

    total_hours_completed = claim.mentor_trainings.sum(:hours_completed)

    amount_in_pence = claims_funding_available_per_hour_pence * total_hours_completed

    Money.new(amount_in_pence, "GBP")
  end
end

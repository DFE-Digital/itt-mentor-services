require "rails_helper"

describe Claims::CalculateAmount do
  let!(:claim) { create(:claim, school_id: school.id, reference: "12345678") }
  let!(:region) { create(:region, name: "Inner London", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP")) }
  let!(:school) { create(:claims_school, :claims, name: "School name 1", region_id: region.id, urn: "1234") }

  include_examples "ServicePatternExamples"

  describe "#call" do
    it "calculates the claim amount" do
      create(:mentor_training, claim:, hours_completed: 10)
      create(:mentor_training, claim:, hours_completed: 10)

      result = described_class.call(claim:)

      expect(result).to eq(Money.new(107_200, "GBP"))
    end
  end
end

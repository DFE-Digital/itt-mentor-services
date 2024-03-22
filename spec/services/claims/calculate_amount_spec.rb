require "rails_helper"

describe Claims::CalculateAmount do
  let!(:claim) { create(:claim, school_id: school.id, reference: "12345678") }
  let!(:school) { create(:claims_school, :claims, name: "School name 1", region: regions(:inner_london), urn: "1234") }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "calculates the claim amount" do
      create(:mentor_training, claim:, hours_completed: 10)
      create(:mentor_training, claim:, hours_completed: 10)

      result = described_class.call(claim:)

      expect(result).to eq(Money.new(107_200, "GBP"))
    end
  end
end

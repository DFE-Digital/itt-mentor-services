require "rails_helper"

describe Claims::Claim::Forecast do
  it_behaves_like "a service object" do
    let(:params) { { claim_window: create(:claim_window, :current) } }
  end

  describe "#call" do
    it "totals non-draft claims by group and type of establishment for the claim window" do
      claim_window = create(:claim_window, :current)
      school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
      claim = create(:claim, :submitted, school:, claim_window:)
      create(:mentor_training, claim:, hours_completed: 10)
      create(:claim, :draft, school:, claim_window:)

      result = described_class.call(claim_window:)

      expect(result.groups.map(&:name)).to eq(%w[Academies])
      expect(result.groups.first.rows.map(&:type_of_establishment)).to eq(["Academy converter"])
      expect(result.groups.first.total).to eq(claim.amount)
      expect(result.total).to eq(claim.amount)
    end

    it "only totals claims with the given status when a status is provided" do
      claim_window = create(:claim_window, :current)
      school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
      submitted_claim = create(:claim, :submitted, school:, claim_window:)
      paid_claim = create(:claim, :submitted, status: :paid, school:, claim_window:)
      [submitted_claim, paid_claim].each { |claim| create(:mentor_training, claim:, hours_completed: 10) }

      result = described_class.call(claim_window:, status: :submitted)

      expect(result.groups.first.total).to eq(submitted_claim.amount)
      expect(result.total).to eq(submitted_claim.amount)
    end

    it "returns a zero total when there are no claims" do
      result = described_class.call(claim_window: create(:claim_window, :current))

      expect(result.groups).to eq([])
      expect(result.total).to eq(Money.new(0, "GBP"))
    end
  end
end

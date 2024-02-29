require "rails_helper"

RSpec.describe Claims::GenerateClaimsCsv do
  subject(:generate_claims_csv) { described_class.call }

  before do
    region1 = create(:region, name: "Inner London", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP"))
    region2 = create(:region, name: "Outer London", claims_funding_available_per_hour: Money.from_amount(48.25, "GBP"))
    region3 = create(:region, name: "Fringe", claims_funding_available_per_hour: Money.from_amount(45.10, "GBP"))

    school1 = create(:claims_school, :claims, name: "School name 1", region: region1, urn: "1234")
    school2 = create(:claims_school, :claims, name: "School name 2", region: region2, urn: "5678")
    school3 = create(:claims_school, :claims, name: "School name 3", region: region3, urn: "5679")

    claim1 = create(:claim, school: school1, reference: "12345678")
    claim2 = create(:claim, school: school2, reference: "12345679")
    claim3 = create(:claim, school: school3, reference: "12345677")
    claim4 = create(:claim, school: school3, reference: "12345671")

    create(:mentor_training, claim: claim1, hours_completed: 10)
    create(:mentor_training, claim: claim2, hours_completed: 10)

    create(:mentor_training, claim: claim3, hours_completed: 8)
    create(:mentor_training, claim: claim3, hours_completed: 5)
    create(:mentor_training, claim: claim3, hours_completed: 2)

    create(:mentor_training, claim: claim4, hours_completed: 1)
    create(:mentor_training, claim: claim4, hours_completed: 1)
  end

  it "inserts the correct headers" do
    expect(generate_claims_csv.lines.first.chomp).to eq("school_name,school_urn,amount,claim_reference_number")
  end

  it "contains all clims" do
    expect(generate_claims_csv.lines.sort).to eq([
      "school_name,school_urn,amount,claim_reference_number\n",
      "School name 1,1234,536.00,12345678\n",
      "School name 2,5678,482.50,12345679\n",
      "School name 3,5679,676.50,12345677\n",
      "School name 3,5679,90.20,12345671\n",
    ].sort)
  end
end

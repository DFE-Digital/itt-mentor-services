require "rails_helper"

RSpec.describe Claims::GenerateClaimsCsv do
  subject(:generate_claims_csv) { described_class.call }

  before do
    school1 = create(:claims_school, :claims, name: "School name 1", region: regions(:inner_london), urn: "1234", local_authority_name: "blah", local_authority_code: "BLA", group: "Academy")
    school2 = create(:claims_school, :claims, name: "School name 2", region: regions(:outer_london), urn: "5678", local_authority_name: "blah", local_authority_code: "BLA", group: "Academy")
    school3 = create(:claims_school, :claims, name: "School name 3", region: regions(:fringe), urn: "5679", local_authority_name: "blah", local_authority_code: "BLA", group: "Academy")

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

  it_behaves_like "a service object"

  it "inserts the correct headers" do
    expect(generate_claims_csv.lines.first.chomp).to eq("reference,urn,school_name,local_authority_name,amount_to_pay,type")
  end

  it "contains all clims" do
    expect(generate_claims_csv.lines.sort).to eq([
      "reference,urn,school_name,local_authority_name,amount_to_pay,type\n",
      "12345678,1234,School name 1,blah,536.00,Academy\n",
      "12345679,5678,School name 2,blah,482.50,Academy\n",
      "12345677,5679,School name 3,blah,676.50,Academy\n",
      "12345671,5679,School name 3,blah,90.20,Academy\n",
    ].sort)
  end
end

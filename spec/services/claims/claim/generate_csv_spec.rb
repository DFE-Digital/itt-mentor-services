require "rails_helper"

RSpec.describe Claims::Claim::GenerateCSV do
  subject(:generate_claims_csv) { described_class.call(claims:) }

  let(:claims) { Claims::Claim.all }

  before do
    school1 = create(:claims_school, :claims, name: "School name 1", region: regions(:inner_london), urn: "1234", local_authority_name: "blah", local_authority_code: "BLA", type_of_establishment: "Academy converter", group: "Academy")
    school2 = create(:claims_school, :claims, name: "School name 2", region: regions(:outer_london), urn: "5678", local_authority_name: "blah", local_authority_code: "BLA", type_of_establishment: "Academy converter", group: "Academy")
    school3 = create(:claims_school, :claims, name: "School name 3", region: regions(:fringe), urn: "5679", local_authority_name: "blah", local_authority_code: "BLA", type_of_establishment: "Academy converter", group: "Academy")

    claim1 = create(:claim, status: :submitted, submitted_at: Time.zone.local(2023, 8, 29, 22, 35, 0), school: school1, reference: "12345678")
    claim2 = create(:claim, status: :submitted, submitted_at: Time.zone.local(2023, 8, 29, 22, 35, 0), school: school2, reference: "12345679")
    claim3 = create(:claim, status: :submitted, submitted_at: Time.zone.local(2023, 8, 29, 22, 35, 0), school: school3, reference: "12345677")
    claim4 = create(:claim, status: :submitted, submitted_at: Time.zone.local(2023, 8, 29, 22, 35, 0), school: school3, reference: "12345671")
    draft_claim = create(:claim, status: :draft, school: school3, reference: "12345670")

    create(:mentor_training, claim: claim1, hours_completed: 10)
    create(:mentor_training, claim: claim2, hours_completed: 10)

    create(:mentor_training, claim: claim3, hours_completed: 8)
    create(:mentor_training, claim: claim3, hours_completed: 5)
    create(:mentor_training, claim: claim3, hours_completed: 2)

    create(:mentor_training, claim: claim4, hours_completed: 1)
    create(:mentor_training, claim: claim4, hours_completed: 1)
    create(:mentor_training, claim: draft_claim, hours_completed: 1)
  end

  it_behaves_like "a service object" do
    let(:params) { { claims: } }
  end

  it "inserts the correct headers" do
    expect(generate_claims_csv.lines.first.chomp).to eq("claim_reference,urn,school_name,local_authority,claim_amount,type_of_establishment,establishment_type,date_submitted,claim_status")
  end

  it "contains all claims" do
    expect(generate_claims_csv.lines.sort).to eq([
      "claim_reference,urn,school_name,local_authority,claim_amount,type_of_establishment,establishment_type,date_submitted,claim_status\n",
      "12345670,5679,School name 3,blah,45.10,Academy converter,Academy,,draft\n",
      "12345671,5679,School name 3,blah,90.20,Academy converter,Academy,2023-08-29T22:35:00Z,submitted\n",
      "12345677,5679,School name 3,blah,676.50,Academy converter,Academy,2023-08-29T22:35:00Z,submitted\n",
      "12345678,1234,School name 1,blah,536.00,Academy converter,Academy,2023-08-29T22:35:00Z,submitted\n",
      "12345679,5678,School name 2,blah,482.50,Academy converter,Academy,2023-08-29T22:35:00Z,submitted\n",
    ].sort)
  end
end

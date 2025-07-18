require "rails_helper"

describe Claims::Clawback::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(claims:) }

  let(:school_a) do
    create(:claims_school,
           region: Region.first,
           name: "School A",
           urn: "aaaaaaaa",
           local_authority_name: "Local Auth A",
           type_of_establishment: "Academy converter",
           group: "Academy")
  end
  let(:school_b) do
    create(:claims_school,
           region: Region.second,
           name: "School B",
           urn: "bbbbbbbb",
           local_authority_name: "Local Auth B",
           group: "Independent schools",
           type_of_establishment: "Other independent school")
  end
  let(:provider) { create(:claims_provider, name: "Springfield Trust") }
  let(:claim_1) { create(:claim, :submitted, status: :clawback_in_progress, school: school_a, reference: "11111111", provider:) }
  let(:claim_2) { create(:claim, :submitted, status: :clawback_in_progress, school: school_b, reference: "22222222", provider:) }
  let(:claim_3) { create(:claim, :submitted, status: :clawback_in_progress, school: school_b, reference: "33333333", provider:) }
  let(:mentor_jane_doe) do
    create(:claims_mentor, schools: [school_a, school_b], first_name: "Jane", last_name: "Doe")
  end
  let(:mentor_john_smith) do
    create(:claims_mentor, schools: [school_a, school_b], first_name: "John", last_name: "Smith")
  end
  let(:mentor_joe_bloggs) do
    create(:claims_mentor, schools: [school_a, school_b], first_name: "Joe", last_name: "Bloggs")
  end
  let(:claim_1_jane_doe_mentor_training) do
    create(:mentor_training,
           mentor: mentor_jane_doe,
           claim: claim_1,
           hours_completed: 20,
           not_assured: true,
           reason_not_assured: "Invalid claim",
           hours_clawed_back: 20,
           reason_clawed_back: "Invalid claim")
  end
  let(:claim_2_jane_doe_mentor_training) do
    create(:mentor_training,
           mentor: mentor_jane_doe,
           claim: claim_2,
           hours_completed: 18,
           not_assured: true,
           reason_not_assured: "Invalid hours given",
           hours_clawed_back: 2,
           reason_clawed_back: "Invalid hours given")
  end
  let(:claim_2_john_smith_mentor_training) do
    create(:mentor_training,
           mentor: mentor_john_smith,
           claim: claim_2,
           hours_completed: 20,
           not_assured: true,
           reason_not_assured: "Mentor absent",
           hours_clawed_back: 20,
           reason_clawed_back: "Invalid claim")
  end
  let(:claim_2_joe_bloggs_mentor_training) do
    create(:mentor_training,
           mentor: mentor_joe_bloggs,
           claim: claim_2,
           hours_completed: 10,
           not_assured: true,
           reason_not_assured: "Mentor not recognised",
           hours_clawed_back: 10,
           reason_clawed_back: "Invalid claim")
  end
  let(:claim_3_joe_bloggs_mentor_training) do
    create(:mentor_training,
           mentor: mentor_joe_bloggs,
           claim: claim_3,
           hours_completed: 5,
           not_assured: true,
           reason_not_assured: "Invalid claim",
           hours_clawed_back: 5,
           reason_clawed_back: "Invalid claim")
  end
  let(:claims) { Claims::Claim.where(id: [claim_1.id, claim_2.id]).order(:reference) }

  before do
    claim_1_jane_doe_mentor_training
    claim_2_jane_doe_mentor_training
    claim_2_john_smith_mentor_training
    claim_2_joe_bloggs_mentor_training
    claim_3_joe_bloggs_mentor_training
  end

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path)

      expect(csv.first).to eq(%w[
        claim_reference
        school_urn
        school_name
        school_local_authority
        provider_name
        claim_amount
        clawback_amount
        school_type_of_establishment
        school_group
        claim_submission_date
        claim_status
      ])
      expect(csv[1]).to eq(
        [
          "11111111",
          "aaaaaaaa",
          "School A",
          "Local Auth A",
          "Springfield Trust",
          "876.00",
          "876.00",
          "Academy converter",
          "Academy",
          claim_1.submitted_at&.iso8601,
          "clawback_in_progress",
        ],
      )
      expect(csv[2]).to eq(
        [
          "22222222",
          "bbbbbbbb",
          "School B",
          "Local Auth B",
          "Springfield Trust",
          "2316.00",
          "1544.00",
          "Other independent school",
          "Independent schools",
          claim_2.submitted_at&.iso8601,
          "clawback_in_progress",
        ],
      )
    end
  end
end

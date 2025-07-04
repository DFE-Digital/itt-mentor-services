require "rails_helper"

describe Claims::ClawbackResponse::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(csv_content:) }

  let(:school_a) do
    create(:claims_school,
           region: Region.first,
           name: "School A",
           urn: "aaaaaaaa",
           local_authority_name: "Local Auth A",
           type_of_establishment: "Academy converter",
           group: "Academy")
  end
  let(:claim_1) { create(:claim, :submitted, status: :clawback_in_progress, school: school_a, reference: "11111111") }
  let(:mentor_jane_doe) do
    create(:claims_mentor, schools: [school_a], first_name: "Jane", last_name: "Doe")
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

  let(:csv_content) { "claim_reference,school_urn,school_name,school_local_authority,claim_amount,clawback_amount,school_type_of_establishment,school_group,claim_submission_date,claim_status,provider_name\n11111111,aaaaaaaa,School A,Local Auth A,876.00,876.00,Academy converter,Academy,#{claim_1.submitted_at&.iso8601},clawback_in_progress,Springfield Trust" }

  before { claim_1_jane_doe_mentor_training }

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
    end
  end
end

require "rails_helper"

describe Claims::Sampling::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(claims:, provider_name:) }

  let(:school) { create(:claims_school, name: "School A", urn: "aaaaaaaa", local_authority_name: "Local Auth A", type_of_establishment: "Academy converter", group: "Academy") }
  let(:claims) { create_list(:claim, 3, submitted_at: Time.current, school:, mentor_trainings: [create(:mentor_training, hours_completed: 10)]) }
  let(:provider_name) { "NIOT" }

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
        school_type_of_establishment
        school_group
        provider_name
        claim_submission_date
        mentor_trn
        mentor_full_name
        mentor_hours_of_training
        claim_accepted
        rejection_reason
      ])

      claims.each_with_index do |claim, index|
        expect(csv[index + 1]).to eq([
          claim.reference,
          school.urn,
          school.name,
          school.local_authority_name,
          school.type_of_establishment,
          school.group,
          claim.provider_name,
          claim.submitted_at.iso8601,
          claim.mentor_trainings.first.mentor_trn,
          claim.mentor_trainings.first.mentor_full_name,
          claim.mentor_trainings.first.hours_completed.to_s,
        ])
      end
    end
  end
end

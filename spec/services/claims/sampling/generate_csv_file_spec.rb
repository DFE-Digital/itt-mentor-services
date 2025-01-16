require "rails_helper"

describe Claims::Sampling::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(claims:, provider_name:) }

  let(:claims) { create_list(:claim, 3, mentor_trainings: [create(:mentor_training, hours_completed: 10)]) }
  let(:provider_name) { "NIOT"}

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path)

      expect(csv.first).to eq(%w[
        claim_reference
        sampling_reason
        school_urn
        school_name
        school_postcode
        mentor_full_name
        mentor_hours_of_training
        claim_assured
        claim_not_assured_reason
      ])

      claims.each_with_index do |claim, index|
        expect(csv[index + 1]).to eq([
          claim.reference,
          claim.sampling_reason,
          claim.school.urn,
          claim.school.name,
          claim.school.postcode,
          claim.mentor_trainings.first.mentor_full_name,
          claim.mentor_trainings.first.hours_completed.to_s,
        ])
      end
    end
  end
end

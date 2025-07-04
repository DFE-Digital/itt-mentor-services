require "rails_helper"

describe Claims::SamplingResponse::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(csv_content:, provider_name: "Springfield Trust") }

  let(:csv_content) do
    "claim_reference,school_urn,school_name,school_local_authority,school_type_of_establishment,school_group,claim_submission_date,mentor_full_name,mentor_hours_of_training,claim_accepted,rejection_reason,provider_name\n" \
    "12345678,11111111,School A,London,Free schools 16 to 19,Free Schools,2025-01-27,John Doe,15,true,,Springfield Trust\n" \
    "87654321,22222222,School B,York,Academy sponsor led,Academies,2025-01-27,Jane Doe,10,false,Some reason,Springfield Trust"
  end

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path, headers: true)

      expect(csv.headers).to eq(%w[
        claim_reference
        school_urn
        school_name
        school_local_authority
        school_type_of_establishment
        school_group
        provider_name
        claim_submission_date
        mentor_full_name
        mentor_hours_of_training
        claim_accepted
        rejection_reason
      ])

      first_row = csv[0]
      expect(first_row["claim_reference"]).to eq("12345678")
      expect(first_row["school_urn"]).to eq("11111111")
      expect(first_row["school_name"]).to eq("School A")
      expect(first_row["school_local_authority"]).to eq("London")
      expect(first_row["school_type_of_establishment"]).to eq("Free schools 16 to 19")
      expect(first_row["school_group"]).to eq("Free Schools")
      expect(first_row["claim_submission_date"]).to eq("2025-01-27")
      expect(first_row["mentor_full_name"]).to eq("John Doe")
      expect(first_row["mentor_hours_of_training"]).to eq("15")
      expect(first_row["claim_accepted"]).to eq("true")
      expect(first_row["rejection_reason"]).to be_nil
      expect(first_row["provider_name"]).to eq("Springfield Trust")

      last_row = csv[1]
      expect(last_row["claim_reference"]).to eq("87654321")
      expect(last_row["school_urn"]).to eq("22222222")
      expect(last_row["school_name"]).to eq("School B")
      expect(last_row["school_local_authority"]).to eq("York")
      expect(last_row["school_type_of_establishment"]).to eq("Academy sponsor led")
      expect(last_row["school_group"]).to eq("Academies")
      expect(last_row["claim_submission_date"]).to eq("2025-01-27")
      expect(last_row["mentor_full_name"]).to eq("Jane Doe")
      expect(last_row["mentor_hours_of_training"]).to eq("10")
      expect(last_row["claim_accepted"]).to eq("false")
      expect(last_row["rejection_reason"]).to eq("Some reason")
      expect(last_row["provider_name"]).to eq("Springfield Trust")
    end
  end
end

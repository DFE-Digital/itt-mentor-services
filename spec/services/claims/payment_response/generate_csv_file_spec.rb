require "rails_helper"

describe Claims::PaymentResponse::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(csv_content:) }

  let(:csv_content) do
    "claim_reference,school_urn,school_name,school_local_authority,claim_amount,school_type_of_establishment,school_group,claim_submission_date,claim_status,claim_unpaid_reason,provider_name\n" \
    "12345678,11111111,School A,London,500.00,Free schools 16 to 19,Free Schools,2025-01-27,paid,,Springfield Trust\n" \
    "87654321,22222222,School B,York,999.99,Academy sponsor led,Academies,2025-01-27,unpaid,Some reason,Springfield Trust"
  end

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path, headers: true)

      expect(csv.headers).to eq(
        %w[claim_reference school_urn school_name school_local_authority provider_name claim_amount school_type_of_establishment school_group claim_submission_date claim_status claim_unpaid_reason],
      )

      first_row = csv[0]
      expect(first_row["claim_reference"]).to eq("12345678")
      expect(first_row["school_urn"]).to eq("11111111")
      expect(first_row["school_name"]).to eq("School A")
      expect(first_row["school_local_authority"]).to eq("London")
      expect(first_row["claim_amount"]).to eq("500.00")
      expect(first_row["school_type_of_establishment"]).to eq("Free schools 16 to 19")
      expect(first_row["school_group"]).to eq("Free Schools")
      expect(first_row["claim_submission_date"]).to eq("2025-01-27")
      expect(first_row["claim_status"]).to eq("paid")
      expect(first_row["claim_unpaid_reason"]).to be_nil
      expect(first_row["provider_name"]).to eq("Springfield Trust")

      last_row = csv[1]
      expect(last_row["claim_reference"]).to eq("87654321")
      expect(last_row["school_urn"]).to eq("22222222")
      expect(last_row["school_name"]).to eq("School B")
      expect(last_row["school_local_authority"]).to eq("York")
      expect(last_row["claim_amount"]).to eq("999.99")
      expect(last_row["school_type_of_establishment"]).to eq("Academy sponsor led")
      expect(last_row["school_group"]).to eq("Academies")
      expect(last_row["claim_submission_date"]).to eq("2025-01-27")
      expect(last_row["claim_status"]).to eq("unpaid")
      expect(last_row["claim_unpaid_reason"]).to eq("Some reason")
      expect(last_row["provider_name"]).to eq("Springfield Trust")
    end
  end
end

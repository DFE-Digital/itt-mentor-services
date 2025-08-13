require "rails_helper"

describe Claims::Payments::Claim::GenerateCSVFile do
  subject(:generate_csv_file) do
    described_class.call(claims: Claims::Claim.where(id: claims.pluck(:id)))
  end

  let(:claims) { create_list(:claim, 3) }

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path)

      expect(csv.first).to eq(%w[claim_reference school_urn school_name school_local_authority provider_name claim_amount school_type_of_establishment school_group claim_submission_date claim_status claim_unpaid_reason])

      claims.each_with_index do |claim, index|
        expect(csv[index + 1]).to eq([
          claim.reference,
          claim.school.urn,
          claim.school_name,
          claim.school.local_authority_name,
          claim.provider_name,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.school.type_of_establishment,
          claim.school.group,
          claim.submitted_at&.iso8601,
          claim.status,
        ])
      end
    end
  end
end

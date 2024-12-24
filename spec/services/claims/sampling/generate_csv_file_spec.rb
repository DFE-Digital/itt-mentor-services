require "rails_helper"

describe Claims::Sampling::GenerateCSVFile do
  subject(:generate_csv_file) { described_class.call(claims:) }

  let(:claims) { create_list(:claim, 3) }

  describe "#call" do
    it "generates a CSV file of claims" do
      expect(generate_csv_file).to be_a(CSV)
      expect(generate_csv_file).to be_closed

      csv = CSV.read(generate_csv_file.path)

      expect(csv.first).to eq(%w[claim_reference sampling_reason])

      claims.each_with_index do |claim, index|
        expect(csv[index + 1]).to eq([
          claim.reference,
          claim.sampling_reason,
        ])
      end
    end
  end
end

require "rails_helper"

RSpec.describe Claims::UploadESFAClawbackResponseWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadESFAClawbackResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:grouped_csv_rows).and_return({ "11111111" => [], "22222222" => [] })
    end
  end
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:grouped_csv_rows).to(:wizard) }
  end

  describe "#claims_count" do
    it "returns the number of keys returned by the upload steps grouping of claims references" do
      expect(step.claims_count).to eq(2)
    end
  end
end

require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::ProviderStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(provider_ids: []) }
  end

  describe "#providers" do
    subject(:providers) { step.providers }

    context "when no test providers exist" do
      it "returns an empty list" do
        expect(providers).to eq([])
      end
    end

    context "when test providers exist" do
      let(:test_provider) { create(:provider, name: "Test Provider 123") }
      let(:random_provider) { create(:provider) }

      it "returns only the test providers" do
        expect(providers).to contain_exactly(test_provider)
      end
    end
  end

  describe "#provider_ids" do
    subject(:provider_ids) { step.provider_ids }

    context "when provider_ids is blank" do
      it "returns an empty array" do
        expect(provider_ids).to eq([])
      end
    end

    context "when the provider_ids attribute contains a blank element" do
      let(:attributes) { { provider_ids: ["123", nil] } }

      it "removes the nil element from the provider_ids" do
        expect(provider_ids).to contain_exactly("123")
      end
    end

    context "when the provider_ids attribute contains no blank elements" do
      let(:attributes) { { provider_ids: %w[123 456] } }

      it "returns the provider_ids attribute unchanged" do
        expect(provider_ids).to contain_exactly(
          "123",
          "456",
        )
      end
    end

    context "when the provider_ids attribute contains select_all" do
      let(:attributes) { { provider_ids: ["", "select_all"] } }

      it "returns the provider_ids attribute unchanged" do
        expect(provider_ids).to contain_exactly(
          "select_all",
        )
      end
    end
  end
end

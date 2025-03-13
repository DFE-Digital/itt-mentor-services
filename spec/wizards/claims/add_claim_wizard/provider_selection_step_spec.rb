require "rails_helper"

RSpec.describe Claims::AddClaimWizard::ProviderSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let!(:niot_provider) { create(:claims_provider, :niot) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard)
  end

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:id) }
  end

  describe "#provider" do
    subject { step.provider }

    context "when id is set" do
      context "when the provider is present" do
        let(:attributes) { { id: niot_provider.id } }

        it { is_expected.to eq(niot_provider) }
      end

      context "when the provider is not a valid provider id" do
        let(:attributes) { { id: "123" } }

        it { is_expected.to be_nil }
      end
    end

    context "when id is nil" do
      let(:attributes) { { id: nil } }

      it { is_expected.to be_nil }
    end
  end

  describe "#scope" do
    subject { step.scope }

    it { is_expected.to eq("claims_add_claim_wizard_provider_selection_step") }
  end
end

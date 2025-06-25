require "rails_helper"

RSpec.describe Claims::AddClaimWizard::ProviderStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let(:created_by) { create(:claims_user) }
  let!(:niot_provider) { create(:claims_provider, :niot) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:created_by).and_return(created_by)
    end
  end

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, name: nil) }
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

  describe "#autocomplete_path_value" do
    subject { step.autocomplete_path_value }

    it { is_expected.to eq("/api/provider_suggestions") }
  end

  describe "#autocomplete_return_attributes_value" do
    subject { step.autocomplete_return_attributes_value }

    it { is_expected.to contain_exactly("postcode") }
  end

  describe "#scope" do
    subject { step.scope }

    it { is_expected.to eq("claims_add_claim_wizard_provider_step") }
  end
end

require "rails_helper"

RSpec.describe Claims::AddClaimWizard::ProviderStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let!(:niot_provider) { create(:claims_provider, :niot) }
  let!(:bpn_provider) { create(:claims_provider, :best_practice_network) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard)
  end

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:id).in_array([niot_provider.id, bpn_provider.id]) }
  end

  describe "#providers_for_selection" do
    subject(:providers_for_selection) { step.providers_for_selection }

    before { create(:claims_provider) }

    it "returns only the providers scoped in the private beta" do
      private_beta_providers = Claims::Provider.where(id: [bpn_provider.id, niot_provider.id])
      expect(providers_for_selection).to match_array(private_beta_providers.select(:id, :name))
    end
  end

  describe "#provider" do
    subject { step.provider }

    context "when id is set" do
      context "when the provider is a private beta provider" do
        let(:attributes) { { id: niot_provider.id } }

        it { is_expected.to eq(niot_provider) }
      end

      context "when the provider is not a private beta provider" do
        let(:attributes) { { id: create(:claims_provider).id } }

        it { is_expected.to be_nil }
      end
    end

    context "when id is nil" do
      let(:attributes) { { id: nil } }

      it { is_expected.to be_nil }
    end
  end
end

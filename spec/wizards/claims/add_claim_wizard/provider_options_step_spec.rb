require "rails_helper"

RSpec.describe Claims::AddClaimWizard::ProviderOptionsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let!(:niot_provider) { create(:claims_provider, :niot) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        steps: { provider: mock_provider_step },
      )
    end
  end

  let(:mock_provider_step) do
    instance_double(Claims::AddClaimWizard::ProviderStep).tap do |mock_provider_step|
      allow(mock_provider_step).to receive(:id).and_return(provider_search_name)
    end
  end
  let(:provider_search_name) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, search_param: nil) }
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

  describe "providers" do
    let(:provider_search_name) { "York" }
    let(:liverpool_provider) { create(:claims_provider, name: "Liverpool provider") }
    let!(:york_provider) { create(:claims_provider, name: "York provider") }
    let!(:yorkshire_provider) { create(:claims_provider, name: "Yorkshire provider") }
    let(:york_school) { create(:claims_school, name: "York school") }

    before do
      liverpool_provider
      york_school
    end

    it "returns a list of providers with names similar to the search params" do
      expect(step.providers).to contain_exactly(york_provider, yorkshire_provider)
    end
  end

  describe "search_param" do
    let(:provider_search_name) { "Provider" }

    it "returns the provider search name from the previous step" do
      expect(step.search_param).to eq("Provider")
    end
  end

  describe "#scope" do
    subject(:scope) { step.scope }

    it {
      expect(scope).to eq(
        "claims_add_claim_wizard_provider_options_step",
      )
    }
  end
end

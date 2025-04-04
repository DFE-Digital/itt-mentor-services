require "rails_helper"

RSpec.describe Placements::EditPlacementWizard::ProviderOptionsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(school:, steps: { provider: mock_provider_step })
    end
  end
  let(:mock_provider_step) do
    instance_double(Placements::EditPlacementWizard::ProviderStep).tap do |mock_provider_step|
      allow(mock_provider_step).to receive(:provider_id).and_return(provider_search_name)
    end
  end
  let(:provider_search_name) { nil }

  let(:attributes) { nil }

  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary", partner_providers: [partner_provider]) }

  let(:partner_provider) { build(:provider, :scitt) }
  let(:lead_school_provider) { create(:placements_provider, :lead_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(provider_id: nil) }
  end

  describe "validations" do
    context "when the provider_id is not present" do
      let(:provider_id) { partner_provider.id }

      it { is_expected.to validate_presence_of(:provider_id) }
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
  end

  describe "#provider" do
    subject { step.provider }

    context "when provider_id is set" do
      let(:attributes) { { provider_id: partner_provider.id } }

      it { is_expected.to eq(partner_provider) }
    end

    context "when provider_id is nil" do
      let(:attributes) { { provider_id: nil } }

      it { is_expected.to be_nil }
    end
  end

  describe "providers" do
    let(:provider_search_name) { "York" }
    let(:liverpool_provider) { create(:provider, name: "Liverpool provider") }
    let!(:york_provider) { create(:provider, name: "York provider") }
    let!(:yorkshire_provider) { create(:provider, name: "Yorkshire provider") }
    let(:york_school) { create(:school, name: "York school") }

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
end

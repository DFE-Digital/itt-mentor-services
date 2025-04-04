require "rails_helper"

RSpec.describe Placements::EditPlacementWizard::ProviderSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

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

  describe "#scope" do
    subject(:scope) { step.scope }

    it { is_expected.to eq("placements_#{mock_wizard.class.name.demodulize.underscore}_provider_selection_step") }
  end
end

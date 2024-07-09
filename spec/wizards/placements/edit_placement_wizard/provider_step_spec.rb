require "rails_helper"

RSpec.describe Placements::EditPlacementWizard::ProviderStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }

  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary", partner_providers: [partner_provider]) }

  let(:partner_provider) { build(:placements_provider, :scitt) }
  let(:lead_school_provider) { create(:placements_provider, :lead_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(provider_id: nil) }
  end

  describe "validations" do
    context "when the provider_id is not 'on'" do
      let(:provider_id) { partner_provider.id }

      it { is_expected.to validate_inclusion_of(:provider_id).in_array(school.partner_providers.ids) }
    end
  end

  describe "#providers_for_selection" do
    subject { step.providers_for_selection }

    it { is_expected.to match_array(school.partner_providers) }
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

  it { is_expected.to delegate_method(:school).to(:wizard) }
end

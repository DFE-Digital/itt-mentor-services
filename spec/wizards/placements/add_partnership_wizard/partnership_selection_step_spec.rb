require "rails_helper"

RSpec.describe Placements::AddPartnershipWizard::PartnershipSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPartnershipWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        organisation:,
        partner_organisation_model:,
        partner_organisation_type:,
      )
    end
  end

  let(:organisation) { create(:placements_school) }
  let(:partner_organisation_model) { Provider }
  let(:partner_organisation_type) { "provider" }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "#partner_organisation" do
    let(:attributes) { { id: partner_organisation.id } }

    context "when partner organisation is a provider" do
      let(:partner_organisation) { create(:provider) }

      it "returns the partner organisation" do
        expect(step.partner_organisation).to eq(partner_organisation)
      end
    end

    context "when partner organisation is a school" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation_model) { School }
      let(:partner_organisation_type) { "school" }
      let(:partner_organisation) { create(:school) }

      it "returns the partner organisation" do
        expect(step.partner_organisation).to eq(partner_organisation)
      end
    end
  end

  describe "#partner_organisation_name" do
    let(:attributes) { { id: partner_organisation.id } }

    context "when partner organisation is a provider" do
      let(:partner_organisation) { create(:provider) }

      it "returns the partner organisation's name" do
        expect(step.partner_organisation_name).to eq(partner_organisation.name)
      end
    end

    context "when partner organisation is a school" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation_model) { School }
      let(:partner_organisation_type) { "school" }
      let(:partner_organisation) { create(:school) }

      it "returns the partner organisation" do
        expect(step.partner_organisation_name).to eq(partner_organisation.name)
      end
    end
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "placements_#{mock_wizard.class.name.demodulize.underscore}_partnership_selection_step",
      )
    end
  end
end

require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard::OrganisationSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddOrganisationWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(organisation_type:, organisation_model:)
    end
  end

  let(:attributes) { nil }
  let(:organisation_type) { "school" }
  let(:organisation_model) { School }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "#organisation" do
    let(:attributes) { { id: organisation.id } }

    context "when the organisation is a school" do
      let(:organisation) { create(:school) }

      it "returns the school record" do
        expect(step.organisation).to eq(organisation)
      end
    end

    context "when the organisation is a provider" do
      let(:organisation) { create(:provider) }
      let(:organisation_type) { "provider" }
      let(:organisation_model) { Provider }

      it "returns the provider record" do
        expect(step.organisation).to eq(organisation)
      end
    end
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "placements_#{mock_wizard.class.name.demodulize.underscore}_organisation_selection_step",
      )
    end
  end
end

require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddOrganisationWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        steps: { organisation: organisation_step, organisation_options: organisation_options_step },
      )
    end
  end

  let(:organisation_step) do
    instance_double(Placements::AddOrganisationWizard::OrganisationStep).tap do |organisation_step|
      allow(organisation_step).to receive(:organisation).and_return(organisation_step_organisation)
    end
  end

  let(:organisation_options_step) do
    instance_double(Placements::AddOrganisationWizard::OrganisationOptionsStep).tap do |organisation_step|
      allow(organisation_step).to receive(:organisation).and_return(organisation_options_step_organisation)
    end
  end

  let(:attributes) { nil }
  let(:organisation_step_organisation) { nil }
  let(:organisation_options_step_organisation) { nil }

  describe "#organisation" do
    context "when the organisation was selected in the organisation options step" do
      let(:organisation_options_step_organisation) { create(:school) }

      it "returns to organisation selected in the organisation options step" do
        expect(step.organisation).to eq(organisation_options_step_organisation)
      end
    end

    context "when the organisation was selected in the organisation step" do
      let(:organisation_step_organisation) { create(:school) }

      it "returns to organisation selected in the organisation options step" do
        expect(step.organisation).to eq(organisation_step_organisation)
      end
    end
  end
end

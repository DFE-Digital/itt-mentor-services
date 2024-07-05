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

  describe "validations" do
    describe "#id_presence" do
      context "when id is not present" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:id]).to include(
            "can't be blank",
          )
        end
      end
    end

    describe "organisation_already_onboarded?" do
      let(:attributes) { { id: organisation.id } }

      context "when the organisation is already onboarded onto the placements service" do
        context "when the organisation is a school" do
          let(:organisation) { create(:school, :placements) }

          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "#{organisation.name} has already been added. Try another school",
            )
          end
        end

        context "when the organisation is a provider" do
          let(:organisation) { create(:provider, :placements) }
          let(:organisation_type) { "provider" }
          let(:organisation_model) { Provider }

          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "#{organisation.name} has already been added. Try another provider",
            )
          end
        end
      end
    end
  end

  describe "#organisation" do
    let(:attributes) { { id: organisation.id } }

    context "when the organisation is a school" do
      let(:organisation) { create(:school) }

      it "returns the provider record" do
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

require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard::OrganisationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddOrganisationWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        organisation_type:,
        organisation_model:,
        steps: { organisation_type: organisation_type_step },
      )
    end
  end

  let(:organisation_type_step) do
    instance_double(Placements::AddOrganisationWizard::OrganisationTypeStep).tap do |organisation_type_step|
      allow(organisation_type_step).to receive(:provider?).and_return(is_provider)
    end
  end

  let(:attributes) { nil }
  let(:organisation_type) { "school" }
  let(:organisation_model) { School }
  let(:is_provider) { false }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, name: nil) }
  end

  describe "validations" do
    describe "#id_presence" do
      context "when organisation type is school" do
        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Enter a school name, unique reference number (URN) or postcode",
            )
          end
        end
      end

      context "when organisation type is provider" do
        let(:organisation_type) { "provider" }
        let(:organisation_model) { Provider }
        let(:is_provider) { true }

        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode",
            )
          end
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

  describe "#autocomplete_path_value" do
    context "when organisation type is school" do
      it "returns the URL for school suggestions" do
        expect(step.autocomplete_path_value).to eq("/api/school_suggestions")
      end
    end

    context "when organisation type is provider" do
      let(:organisation_type) { "provider" }
      let(:organisation_model) { Provider }
      let(:is_provider) { true }

      it "returns the URL for provider suggestions" do
        expect(step.autocomplete_path_value).to eq("/api/provider_suggestions")
      end
    end
  end

  describe "#autocomplete_return_attributes_value" do
    context "when organisation type is school" do
      it "returns the attributes returned by the school suggestions api" do
        expect(step.autocomplete_return_attributes_value).to match_array(%w[town postcode])
      end
    end

    context "when organisation type is provider" do
      let(:organisation_type) { "provider" }
      let(:organisation_model) { Provider }
      let(:is_provider) { true }

      it "returns the attributes returned by the provider suggestions api" do
        expect(step.autocomplete_return_attributes_value).to match_array(%w[code])
      end
    end
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "placements_#{mock_wizard.class.name.demodulize.underscore}_organisation_step",
      )
    end
  end

  describe "#organisation_name" do
    context "when organisation is nil" do
      let(:organisation_type) { nil }
      let(:organisation_model) { nil }
      let(:is_provider) { false }

      it "returns nil" do
        expect(step.organisation_name).to be_nil
      end
    end

    context "when organisation is present" do
      let(:organisation) { create(:school, :placements) }
      let(:attributes) { { id: organisation.id } }

      it "returns the name of the organisation" do
        expect(step.organisation_name).to eq(organisation.name)
      end
    end
  end
end

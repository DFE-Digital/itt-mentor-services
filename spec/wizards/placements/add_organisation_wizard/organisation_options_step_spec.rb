require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard::OrganisationOptionsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddOrganisationWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        organisation_type:,
        organisation_model:,
        steps: { organisation_type: organisation_type_step, organisation: organisation_step },
      )
    end
  end

  let(:organisation_type_step) do
    instance_double(Placements::AddOrganisationWizard::OrganisationTypeStep).tap do |organisation_type_step|
      allow(organisation_type_step).to receive(:provider?).and_return(is_provider)
    end
  end

  let(:organisation_step) do
    instance_double(Placements::AddOrganisationWizard::OrganisationStep).tap do |organisation_step|
      allow(organisation_step).to receive(:id).and_return(organisation_search_name)
    end
  end

  let(:attributes) { nil }
  let(:organisation_search_name) { nil }
  let(:organisation_type) { "school" }
  let(:organisation_model) { School }
  let(:is_provider) { false }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, search_param: nil) }
  end

  describe "validations" do
    describe "#id_presence" do
      context "when organisation type is school" do
        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Select a school",
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
              "Select a provider",
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

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "placements_#{mock_wizard.class.name.demodulize.underscore}_organisation_options_step",
      )
    end
  end

  describe "#organisations" do
    let(:organisation_search_name) { "York" }

    context "when the organisation type is school" do
      let(:organisation_type) { "school" }
      let(:organisation_model) { School }
      let(:is_provider) { false }

      let(:liverpool_school) { create(:school, name: "Liverpool school") }
      let(:york_provider) { create(:provider, name: "York provider") }
      let!(:yorkshire_school) { create(:school, name: "Yorkshire school") }
      let!(:york_school) { create(:school, name: "York school") }

      before do
        liverpool_school
        york_provider
      end

      it "returns a list of schools with names similar to the search params" do
        expect(step.organisations).to contain_exactly(york_school, yorkshire_school)
      end
    end

    context "when the organisation type is provider" do
      let(:organisation_type) { "provider" }
      let(:organisation_model) { Provider }
      let(:is_provider) { true }

      let(:liverpool_provider) { create(:provider, name: "Liverpool provider") }
      let!(:york_provider) { create(:provider, name: "York provider") }
      let!(:yorkshire_provider) { create(:provider, name: "Yorkshire provider") }
      let(:york_school) { create(:school, name: "York school") }

      before do
        liverpool_provider
        york_school
      end

      it "returns a list of providers with names similar to the search params" do
        expect(step.organisations).to contain_exactly(york_provider, yorkshire_provider)
      end
    end
  end

  describe "search_params" do
    let(:organisation_search_name) { "School" }

    context "when the search_param attribute is present" do
      let(:attributes) { { search_param: "Organisation" } }

      it "returns the search param" do
        expect(step.search_params).to eq("Organisation")
      end
    end

    context "when the search_param attribute is not present" do
      it "returns the organisation search name" do
        expect(step.search_params).to eq("School")
      end
    end
  end
end

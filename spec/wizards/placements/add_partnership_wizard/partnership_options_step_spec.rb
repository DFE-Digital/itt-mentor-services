require "rails_helper"

RSpec.describe Placements::AddPartnershipWizard::PartnershipOptionsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPartnershipWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        organisation:,
        partner_organisation_model:,
        partner_organisation_type:,
        steps: { partnership: partnership_step },
      )
    end
  end

  let(:partnership_step) do
    instance_double(Placements::AddPartnershipWizard::PartnershipStep).tap do |partnership_step|
      allow(partnership_step).to receive(:id).and_return(organisation_search_name)
    end
  end

  let(:organisation) { create(:placements_school) }
  let(:partner_organisation_model) { Provider }
  let(:partner_organisation_type) { "provider" }
  let(:attributes) { nil }
  let(:organisation_search_name) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, search_param: nil) }
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "placements_#{mock_wizard.class.name.demodulize.underscore}_partnership_options_step",
      )
    end
  end

  describe "validations" do
    describe "#id_presence" do
      context "when partner organisation is a provider" do
        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Select a provider",
            )
          end
        end
      end

      context "when partner organisation is a school" do
        let(:organisation) { create(:placements_provider) }
        let(:partner_organisation_model) { School }
        let(:partner_organisation_type) { "school" }

        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Select a school",
            )
          end
        end
      end
    end

    describe "#new_partnership" do
      context "when a partnership between the organisation and partner organisation already exists" do
        let(:attributes) { { id: partner_organisation.id } }

        context "when partner organisation is a provider" do
          before { create(:placements_partnership, school: organisation, provider: partner_organisation) }

          let(:partner_organisation) { create(:provider) }

          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "#{partner_organisation.name} has already been added. Try another provider",
            )
          end
        end

        context "when partner organisation is a school" do
          before { create(:placements_partnership, school: partner_organisation, provider: organisation) }

          let(:organisation) { create(:placements_provider) }
          let(:partner_organisation_model) { School }
          let(:partner_organisation_type) { "school" }
          let(:partner_organisation) { create(:school) }

          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "#{partner_organisation.name} has already been added. Try another school",
            )
          end
        end
      end
    end
  end

  describe "#partnership_options" do
    let(:organisation_search_name) { "York" }

    context "when the partner organisation is a provider" do
      let(:liverpool_provider) { create(:provider, name: "Liverpool provider") }
      let!(:york_provider) { create(:provider, name: "York provider") }
      let!(:yorkshire_provider) { create(:provider, name: "Yorkshire provider") }
      let(:york_school) { create(:school, name: "York school") }

      before do
        liverpool_provider
        york_school
      end

      it "returns a list of providers with names similar to the search params" do
        expect(step.partnership_options).to contain_exactly(york_provider, yorkshire_provider)
      end
    end

    context "when the partner organisation is a school" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation_model) { School }
      let(:partner_organisation_type) { "school" }

      let(:liverpool_school) { create(:school, name: "Liverpool school") }
      let(:york_provider) { create(:provider, name: "York provider") }
      let!(:yorkshire_school) { create(:school, name: "Yorkshire school") }
      let!(:york_school) { create(:school, name: "York school") }

      before do
        liverpool_school
        york_provider
      end

      it "returns a list of schools with names similar to the search params" do
        expect(step.partnership_options).to contain_exactly(york_school, yorkshire_school)
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

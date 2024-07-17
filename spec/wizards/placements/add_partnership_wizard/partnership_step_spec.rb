require "rails_helper"

RSpec.describe Placements::AddPartnershipWizard::PartnershipStep, type: :model do
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
    it { is_expected.to have_attributes(id: nil, name: nil) }
  end

  describe "validations" do
    describe "#id_presence" do
      context "when partner organisation is a provider" do
        context "when id is not present" do
          it "returns invalid" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:id]).to include(
              "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode",
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
              "Enter a school name, unique reference number (URN) or postcode",
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
        "placements_#{mock_wizard.class.name.demodulize.underscore}_partnership_step",
      )
    end
  end

  describe "#autocomplete_path_value" do
    context "when partner organisation is a provider" do
      it "returns the URL for provider suggestions" do
        expect(step.autocomplete_path_value).to eq("/api/provider_suggestions")
      end
    end

    context "when partner organisation is a school" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation_model) { School }
      let(:partner_organisation_type) { "school" }
      let(:partner_organisation) { create(:school) }

      it "returns the URL for school suggestions" do
        expect(step.autocomplete_path_value).to eq("/api/school_suggestions")
      end
    end
  end

  describe "#autocomplete_return_attributes_value" do
    context "when organisation type is a provider" do
      it "returns the attributes returned by the provider suggestions api" do
        expect(step.autocomplete_return_attributes_value).to match_array(%w[code])
      end
    end

    context "when organisation type is a school" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation_model) { School }
      let(:partner_organisation_type) { "school" }
      let(:partner_organisation) { create(:school) }

      it "returns the attributes returned by the school suggestions api" do
        expect(step.autocomplete_return_attributes_value).to match_array(%w[town postcode])
      end
    end
  end
end

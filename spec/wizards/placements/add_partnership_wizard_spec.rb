require "rails_helper"

RSpec.describe Placements::AddPartnershipWizard do
  subject(:wizard) { described_class.new(organisation:, session:, params:, current_step: nil) }

  let(:session) { { "Placements::AddPartnershipWizard" => state } }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:organisation) { create(:placements_school) }
  let(:partner_organisation) { create(:provider) }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when an organisation was selected during the organsation step" do
      let(:state) do
        {
          "partnership" => { "id" => partner_organisation.id, "name" => partner_organisation.name },
        }
      end

      it { is_expected.to eq %i[partnership check_your_answers] }
    end

    context "when an organisation was not selected during the organsation step" do
      it { is_expected.to eq %i[partnership partnership_options check_your_answers] }
    end
  end

  describe "#partner_organisation" do
    subject { wizard.partner_organisation }

    context "when partnership is set in the partnership step" do
      context "when organisation is a school" do
        let(:state) do
          {
            "partnership" => { "id" => partner_organisation.id, "name" => partner_organisation.name },
          }
        end

        it { is_expected.to eq(partner_organisation) }
      end

      context "when organisation is a provider" do
        let(:organisation) { create(:placements_provider) }
        let(:partner_organisation) { create(:school) }
        let(:state) do
          {
            "partnership" => { "id" => partner_organisation.id, "name" => partner_organisation.name },
          }
        end

        it { is_expected.to eq(partner_organisation) }
      end
    end

    context "when partnership is set in the partnership options step" do
      context "when organisation is a school" do
        let(:state) do
          {
            "partnership_options" => { "id" => partner_organisation.id },
          }
        end

        it { is_expected.to eq(partner_organisation) }
      end

      context "when organisation is a provider" do
        let(:organisation) { create(:placements_provider) }
        let(:partner_organisation) { create(:school) }
        let(:state) do
          {
            "partnership_options" => { "id" => partner_organisation.id },
          }
        end

        it { is_expected.to eq(partner_organisation) }
      end
    end
  end

  describe "#create_partnership" do
    context "when organisation is a school" do
      let(:state) do
        {
          "partnership" => { "id" => partner_organisation.id, "name" => partner_organisation.name },
        }
      end

      it "creates a partnership between the organisation and partner organisation" do
        expect { wizard.create_partnership }.to change(Placements::Partnership, :count).by(1)
        expect(organisation.partner_providers).to contain_exactly(partner_organisation)
      end
    end

    context "when organisation is a provider" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation) { create(:school) }
      let(:state) do
        {
          "partnership" => { "id" => partner_organisation.id, "name" => partner_organisation.name },
        }
      end

      it "creates a partnership between the organisation and partner organisation" do
        expect { wizard.create_partnership }.to change(Placements::Partnership, :count).by(1)
        expect(organisation.partner_schools).to contain_exactly(partner_organisation)
      end
    end
  end

  describe "#partner_organisation_type" do
    context "when organisation is a school" do
      it "returns the partner organisation model as a string" do
        expect(wizard.partner_organisation_type).to eq("provider")
      end
    end

    context "when organisation is a provider" do
      let(:organisation) { create(:placements_provider) }
      let(:partner_organisation) { create(:school) }

      it "returns the partner organisation model as a string" do
        expect(wizard.partner_organisation_type).to eq("school")
      end
    end
  end
end

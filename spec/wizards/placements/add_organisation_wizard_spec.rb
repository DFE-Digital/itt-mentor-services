require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard do
  subject(:wizard) { described_class.new(session:, params:, current_step: nil) }

  let(:session) { { "Placements::AddOrganisationWizard" => state } }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when an organisation was selected during the organsation step" do
      let!(:organisation) { create(:school) }
      let(:state) do
        {
          "organisation_type" => { "organisation_type" => "school" },
          "organisation" => { "id" => organisation.id, "name" => organisation.name },
        }
      end

      it { is_expected.to eq %i[organisation_type organisation check_your_answers] }
    end

    context "when an organisation was not selected during the organsation step" do
      it { is_expected.to eq %i[organisation_type organisation organisation_options check_your_answers] }
    end
  end

  describe "#organisation_type" do
    subject { wizard.organisation_type }

    context "when organisation type step is set to school" do
      let(:state) do
        { "organisation_type" => { "organisation_type" => "school" } }
      end

      it { is_expected.to eq("school") }
    end

    context "when organisation type step is set to provider" do
      let(:state) do
        { "organisation_type" => { "organisation_type" => "provider" } }
      end

      it { is_expected.to eq("provider") }
    end

    context "when organisation type step is not set" do
      it { is_expected.to be_nil }
    end
  end

  describe "#organisation_model" do
    subject { wizard.organisation_model }

    context "when organisation type step is set to school" do
      let(:state) do
        { "organisation_type" => { "organisation_type" => "school" } }
      end

      it { is_expected.to eq(School) }
    end

    context "when organisation type step is set to provider" do
      let(:state) do
        { "organisation_type" => { "organisation_type" => "provider" } }
      end

      it { is_expected.to eq(Provider) }
    end

    context "when organisation type step is set to nil" do
      let(:state) do
        { "organisation_type" => { "organisation_type" => nil } }
      end

      it { is_expected.to be_nil }
    end

    context "when organisation type step is not set" do
      it { is_expected.to be_nil }
    end
  end

  describe "#organisation" do
    subject { wizard.organisation }

    context "when organisation is a school" do
      let!(:organisation) { create(:school) }
      let(:state) do
        {
          "organisation_type" => { "organisation_type" => "school" },
          "organisation" => { "id" => organisation.id, "name" => organisation.name },
        }
      end

      it { is_expected.to eq(organisation) }
    end

    context "when organisation is a provider" do
      let!(:organisation) { create(:provider) }
      let(:state) do
        {
          "organisation_type" => { "organisation_type" => "provider" },
          "organisation" => { "id" => organisation.id, "name" => organisation.name },
        }
      end

      it { is_expected.to eq(organisation) }
    end
  end

  describe "#onboard_organisation" do
    context "when organisation is a school" do
      let!(:organisation) { create(:school) }
      let(:state) do
        {
          "organisation_type" => { "organisation_type" => "school" },
          "organisation" => { "id" => organisation.id, "name" => organisation.name },
        }
      end

      it "onboards the school into the placements service" do
        expect(organisation.placements_service).to be(false)
        wizard.onboard_organisation
        organisation.reload
        expect(organisation.placements_service).to be(true)
      end
    end

    context "when organisation is a provider" do
      let!(:organisation) { create(:provider) }
      let(:state) do
        {
          "organisation_type" => { "organisation_type" => "provider" },
          "organisation" => { "id" => organisation.id, "name" => organisation.name },
        }
      end

      it "onboards the school into the placements service" do
        expect(organisation.placements_service).to be(false)
        wizard.onboard_organisation
        organisation.reload
        expect(organisation.placements_service).to be(true)
      end
    end
  end
end

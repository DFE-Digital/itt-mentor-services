require "rails_helper"

RSpec.describe Claims::AddOrganisationWizard do
  subject(:wizard) { described_class.new(current_user:, state:, params:, current_step: nil) }

  let(:current_user) { create(:claims_support_user) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no current or upcoming claim windows" do
      it { is_expected.to eq(%i[no_claim_window]) }
    end

    context "when there a current or upcoming claim windows" do
      let(:current_claim_window) { create(:claim_window, :current) }

      before { current_claim_window }

      context "when an school was selected during the school step" do
        let!(:school) { create(:school) }
        let(:state) do
          {
            "school" => { "id" => school.id, "name" => school.name },
          }
        end

        it { is_expected.to eq %i[name vendor_number region address contact_details check_your_answers] }
      end
    end
  end

  describe "#organisation" do
    subject(:organisation) { wizard.organisation }

    let(:current_claim_window) { create(:claim_window, :current) }
    let(:region) { Region.first }
    let(:name) { "Test School" }
    let(:vendor_number) { "123456" }
    let(:address1) { "123 Test Street" }
    let(:address2) { "Test House" }
    let(:postcode) { "AB12 3CD" }
    let(:town) { "Test Town" }
    let(:website) { "https://www.testschool.com" }
    let(:telephone) { "01234 567890" }

    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
        "name" => {
          "name" => name,
        },
        "vendor_number" => {
          "vendor_number" => vendor_number,
        },
        "region" => {
          "region_id" => region.id,
        },
        "address" => {
          "address1" => address1,
          "address2" => address2,
          "postcode" => postcode,
          "town" => town,
        },
        "contact_details" => {
          "website" => website,
          "telephone" => telephone,
        },
      }
    end

    it "builds a new organisation" do
      expect(organisation).to be_a(Claims::School)
      expect(organisation.name).to eq(name)
      expect(organisation.vendor_number).to eq(vendor_number)
      expect(organisation.address1).to eq(address1)
      expect(organisation.address2).to eq(address2)
      expect(organisation.postcode).to eq(postcode)
      expect(organisation.town).to eq(town)
      expect(organisation.region_id).to eq(region.id)
      expect(organisation.website).to eq(website)
      expect(organisation.telephone).to eq(telephone)
    end
  end

  describe "#create_organisation" do
    subject(:create_organisation) { wizard.create_organisation }

    let(:current_claim_window) { create(:claim_window, :current) }
    let(:region) { Region.first }
    let(:name) { "Test School" }
    let(:vendor_number) { "123456" }
    let(:address1) { "123 Test Street" }
    let(:address2) { "Test House" }
    let(:postcode) { "AB12 3CD" }
    let(:town) { "Test Town" }
    let(:website) { "https://www.testschool.com" }
    let(:telephone) { "01234 567890" }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
        "name" => {
          "name" => name,
        },
        "vendor_number" => {
          "vendor_number" => vendor_number,
        },
        "region" => {
          "region_id" => region.id,
        },
        "address" => {
          "address1" => address1,
          "address2" => address2,
          "postcode" => postcode,
          "town" => town,
        },
        "contact_details" => {
          "website" => website,
          "telephone" => telephone,
        },
      }
    end

    it "creates a new organisation" do
      expect { create_organisation }.to change(Claims::School, :count).by(1)
      organisation = Claims::School.last
      expect(organisation.name).to eq(name)
      expect(organisation.vendor_number).to eq(vendor_number)
      expect(organisation.address1).to eq(address1)
      expect(organisation.address2).to eq(address2)
      expect(organisation.postcode).to eq(postcode)
      expect(organisation.town).to eq(town)
      expect(organisation.region_id).to eq(region.id)
      expect(organisation.website).to eq(website)
      expect(organisation.telephone).to eq(telephone)
      expect(organisation.eligible_claim_windows).to contain_exactly(current_claim_window)
      expect(organisation.manually_onboarded_by).to eq(current_user)
    end
  end

  describe "#academic_year" do
    subject(:academic_year) { wizard.academic_year }

    let(:current_claim_window) { create(:claim_window, :current) }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
      }
    end

    it "returns the academic year for the specified claim window" do
      expect(academic_year).to eq(current_claim_window.academic_year)
    end
  end
end

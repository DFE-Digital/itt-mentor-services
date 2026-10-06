require "rails_helper"

RSpec.describe Claims::AddClaimWizard::ProviderSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let!(:niot_provider) { make_eligible(create(:claims_provider, :niot)) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard, academic_year:)
  end
  let(:academic_year) { AcademicYear.current }
  let(:other_academic_year) { AcademicYear.for_date(academic_year.ends_on + 1.day) }

  def make_eligible(provider, year = academic_year)
    Claims::ProviderEligibility.find_or_create_by!(provider:, academic_year: year)
    provider
  end

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:id) }
  end

  describe "#provider" do
    subject { step.provider }

    context "when id is set" do
      context "when the provider is present" do
        let(:attributes) { { id: niot_provider.id } }

        it { is_expected.to eq(niot_provider) }
      end

      context "when the provider is only eligible for a different academic year" do
        let(:attributes) { { id: other_provider.id } }
        let(:other_provider) { make_eligible(create(:claims_provider, :best_practice_network, accredited: false), other_academic_year) }

        it { is_expected.to be_nil }
      end

      context "when the provider is flagged as accredited but has no eligibility" do
        let(:attributes) { { id: create(:claims_provider, accredited: true).tap { |p| p.eligibilities.destroy_all }.id } }

        it { is_expected.to be_nil }
      end

      context "when the provider is eligible but not flagged as accredited" do
        let(:attributes) { { id: make_eligible(create(:claims_provider, accredited: false)).id } }

        it { is_expected.to eq(Claims::Provider.find(attributes[:id])) }
      end

      context "when the provider is not a valid provider id" do
        let(:attributes) { { id: "123" } }

        it { is_expected.to be_nil }
      end
    end

    context "when id is nil" do
      let(:attributes) { { id: nil } }

      it { is_expected.to be_nil }
    end
  end

  describe "#scope" do
    subject { step.scope }

    it { is_expected.to eq("claims_add_claim_wizard_provider_selection_step") }
  end
end

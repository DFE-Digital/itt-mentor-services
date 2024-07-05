require "rails_helper"

RSpec.describe Placements::AddOrganisationWizard::OrganisationTypeStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Placements::AddOrganisationWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(organisation_type: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:organisation_type) }

    describe "organisation_type" do
      let(:attributes) { { organisation_type: } }

      context "when the organisation type is school" do
        let(:organisation_type) { "school" }

        it { is_expected.to be_valid }
      end

      context "when the organisation type is provider" do
        let(:organisation_type) { "provider" }

        it { is_expected.to be_valid }
      end

      context "when the organisation type is neither school nor provider" do
        let(:organisation_type) { "Nursery" }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe "#organisation_types_for_selection" do
    it "returns school and provider organisation types" do
      expect(step.organisation_types_for_selection.map(&:name)).to contain_exactly("Teacher training provider", "School")
      expect(step.organisation_types_for_selection.map(&:value)).to match_array(%w[provider school])
    end
  end
end

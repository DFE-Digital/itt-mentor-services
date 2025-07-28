require "rails_helper"

RSpec.describe Claims::ExportUsersWizard::ClaimWindowStep, type: :model do
  subject(:step) { described_class.new(wizard:, attributes:) }

  let(:wizard) { instance_double(Claims::ExportUsersWizard) }
  let(:attributes) { nil }

  context "when selection is nil" do
    it "stores the selected attribute" do
      expect(step).to have_attributes(selection: nil)
    end

    it "raises a validation error" do
      expect(step).not_to be_valid
      expect(step.errors[:selection]).to include("Select which claim windows to include")
    end
  end

  describe "#all_claim_windows?" do
    context "when selection is 'all'" do
      let(:attributes) { { selection: "all" } }

      it "returns true" do
        expect(step.all_claim_windows?).to be(true)
      end
    end

    context "when selection is 'specific'" do
      let(:attributes) { { selection: "specific" } }

      it "returns false" do
        expect(step.all_claim_windows?).to be(false)
      end
    end
  end
end

require "rails_helper"

RSpec.describe Claims::SubmitClaimsToBePaidWizard::SelectClaimWindowStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::SubmitClaimsToBePaidWizard) }
  let(:attributes) { nil }
  let(:current_claim_window) { build(:claim_window, :current) }
  let(:historic_claim_window) { build(:claim_window, :historic) }
  let(:claim) { create(:claim, :submitted, claim_window: current_claim_window) }

  describe "attributes" do
    it { is_expected.to have_attributes(claim_window: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:claim_window) }
  end

  describe "#claim_windows" do
    subject(:claim_windows) { step.claim_windows }

    before do
      claim
      historic_claim_window
    end

    context "when the current claim window has claims" do
      it "returns all claim windows with submitted claims" do
        expect(claim_windows).to contain_exactly(current_claim_window)
      end
    end

    context "when all claim windows have claims" do
      before do
        create(:claim, :submitted, claim_window: historic_claim_window)
      end

      it "returns all claim windows with submitted claims" do
        expect(claim_windows).to contain_exactly(current_claim_window, historic_claim_window)
      end
    end
  end
end

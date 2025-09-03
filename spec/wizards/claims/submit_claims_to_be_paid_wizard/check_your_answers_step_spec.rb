require "rails_helper"

RSpec.describe Claims::SubmitClaimsToBePaidWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::SubmitClaimsToBePaidWizard) }
  let(:claim) { create(:claim, :submitted) }
  let(:attributes) { nil }

  describe "#submitted_claims" do
    subject(:submitted_claims) { step.submitted_claims }

    let(:claim_window) { build(:claim_window, :current) }
    let(:other_claim_window) { build(:claim_window, :historic) }
    let!(:submitted_claim_in_window) { create(:claim, :submitted, claim_window:) }
    let(:submitted_claim_in_other_window) { create(:claim, :submitted, claim_window: other_claim_window) }
    let(:draft_claim_in_window) { create(:claim, :draft, claim_window:) }

    before do
      allow(mock_wizard).to receive_messages(steps: { select_claim_window: instance_double("SelectClaimWindowStep", claim_window:) })
      submitted_claim_in_other_window
      draft_claim_in_window
    end

    it "returns the submitted claims for the selected claim window" do
      expect(submitted_claims).to contain_exactly(submitted_claim_in_window)
    end
  end
end

require "rails_helper"

describe Claims::Claim::Clawback::Complete do
  let!(:claim) { create(:claim, :submitted, status: :clawback_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    context "when given no esfa responses" do
      let(:esfa_responses) { [] }

      it "changes to status of the claim to clawback requested" do
        expect { call }.to change(claim, :status)
          .from("clawback_in_progress")
          .to("clawback_complete")
      end
    end
  end
end

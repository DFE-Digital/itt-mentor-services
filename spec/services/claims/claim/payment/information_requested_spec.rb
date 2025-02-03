require "rails_helper"

describe Claims::Claim::Payment::InformationRequested do
  let!(:claim) { create(:claim, :payment_in_progress) }
  let(:unpaid_reason) { "Some reason" }

  describe "#call" do
    subject(:call) { described_class.call(claim:, unpaid_reason:) }

    it "changes to status of the claim to payment_information_requested" do
      expect { call }.to change(claim, :status)
        .from("payment_in_progress")
        .to("payment_information_requested")
        .and change(claim, :unpaid_reason).from(nil).to("Some reason")
    end
  end
end

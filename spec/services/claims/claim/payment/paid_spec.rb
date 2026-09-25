require "rails_helper"

describe Claims::Claim::Payment::Paid do
  let!(:claim) { create(:claim, :payment_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:) }

    it "changes to status of the claim to paid" do
      expect { call }.to change(claim, :status)
        .from("payment_in_progress")
        .to("paid")
    end

    context "when payment details are given" do
      subject(:call) do
        described_class.call(claim:, paid_to_la: true, date_paid: "2026-09-21")
      end

      it "stores the payment details against the claim" do
        call

        expect(claim.reload).to have_attributes(
          status: "paid",
          paid_to_la: true,
          date_paid: Time.zone.parse("2026-09-21"),
        )
      end
    end
  end
end

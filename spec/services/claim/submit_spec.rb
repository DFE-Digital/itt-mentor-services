require "rails_helper"

describe Claim::Submit do
  subject(:submit_service) { described_class.call(claim:) }

  let!(:claim) { create(:claim, :draft) }

  describe "#call" do
    it "submits the claim" do
      allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)
      allow(Time).to receive(:current).and_return("2024-03-04 10:32:04 UTC")

      expect { submit_service }.to change(claim, :reference).from(nil).to("123")
      expect(claim.draft).to eq(false)
      expect(claim.submitted_at).to eq(Time.current)
    end

    context "when claim reference is already taken" do
      it "submits the claim with a new reference" do
        create(:claim, reference: "123")
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123, 456)
        allow(Time).to receive(:current).and_return("2024-03-04 10:32:04 UTC")

        expect { submit_service }.to change(claim, :reference).from(nil).to("456")

        expect(claim.draft).to eq(false)
        expect(claim.submitted_at).to eq(Time.current)
      end
    end
  end
end

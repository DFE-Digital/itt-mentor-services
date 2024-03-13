require "rails_helper"

describe Claims::Submit do
  subject(:submit_service) { described_class.call(claim:, claim_params:) }

  let!(:claim) { create(:claim, reference: nil) }
  let(:claim_params) { { status: "submitted", submitted_at: } }
  let(:submitted_at) { Time.new("2024-03-04 10:32:04 UTC") }

  describe "#call" do
    it "submits the claim" do
      allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

      expect { submit_service }.to change(claim, :reference).from(nil).to("123")
      expect(claim.status).to eq("submitted")
      expect(claim.submitted_at).to eq(submitted_at)
    end

    context "when claim has a reference already" do
      it "submits the claim with a new reference" do
        claim_with_reference = create(:claim, reference: "123")
        service = described_class.call(claim: claim_with_reference, claim_params:)

        expect { service }.not_to change(claim, :reference)
      end
    end

    context "when claim reference is already taken" do
      it "submits the claim with a new reference" do
        create(:claim, reference: "123")
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123, 456)

        expect { submit_service }.to change(claim, :reference).from(nil).to("456")

        expect(claim.status).to eq("submitted")
        expect(claim.submitted_at).to eq(submitted_at)
      end
    end

    context "when claim params contains draft status" do
      let(:claim_params) { { status: "draft" } }

      it "submits the claim" do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        expect { submit_service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("draft")
        expect(claim.submitted_at).to be_nil
      end
    end
  end
end

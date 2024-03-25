require "rails_helper"

describe Claims::Claim::Submit do
  subject(:submit_service) { described_class.call(claim:, user:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal, school:) }

  let(:submitted_at) { Time.new("2024-03-04 10:32:04 UTC") }
  let(:school) { create(:claims_school, urn: "1234") }
  let(:user) { create(:claims_user) }

  it_behaves_like "a service object" do
    let(:params) { { claim:, user: } }
  end

  describe "#call" do
    it "submits the claim" do
      allow(Time).to receive(:current).and_return(submitted_at)
      allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

      expect { submit_service }.to change(claim, :reference).from(nil).to("123")
      expect(claim.status).to eq("submitted")
      expect(claim.submitted_at).to eq(submitted_at)

      expect(submit_service.arguments.first).to eq("UserMailer")
      expect(submit_service.arguments.second).to eq("claim_submitted_notification")
    end

    context "when claim has a reference already" do
      it "does not change the existing reference" do
        claim_with_reference = create(:claim, reference: "123")
        service = described_class.call(claim: claim_with_reference, user:)

        expect { service }.not_to change(claim, :reference)
      end
    end

    context "when claim status has not changed" do
      it "does not send any emails" do
        submitted_claim = create(:claim, status: :submitted, school:)
        service = described_class.call(claim: submitted_claim, user:)

        expect(service).to be_nil
        expect(UserMailer).not_to receive(:with).with(any_args)
      end
    end

    context "when claim reference is already taken" do
      it "submits the claim with a new reference" do
        allow(Time).to receive(:current).and_return(submitted_at)
        create(:claim, reference: "123")
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123, 456)

        expect { submit_service }.to change(claim, :reference).from(nil).to("456")

        expect(claim.status).to eq("submitted")
        expect(claim.submitted_at).to eq(submitted_at)
      end
    end
  end
end

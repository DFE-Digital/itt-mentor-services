require "rails_helper"

describe Claims::Claim::CreateDraft do
  subject(:draft_service) { described_class.call(claim:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal_draft, school:) }
  let(:school) { create(:claims_school, urn: "1234") }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "create draft claim" do
      allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)
      create(:claims_user, email: "babagoli@gmail.com", user_memberships: [create(:user_membership, organisation: school)])
      create(:claims_user, email: "email@gmail.com", user_memberships: [create(:user_membership, organisation: school)])

      mailer_stub = class_double("mailer")
      expect(UserMailer).to receive(:with).with(any_args).twice.and_return(mailer_stub)
      expect(mailer_stub).to receive(:claim_created_support_notification).twice.and_return(mailer_stub)
      expect(mailer_stub).to receive(:deliver_later).twice

      expect { draft_service }.to change(claim, :reference).from(nil).to("123")
      expect(claim.status).to eq("draft")
    end

    context "when claim has a reference already" do
      it "does not change the existing reference" do
        claim_with_reference = create(:claim, reference: "123")
        service = described_class.call(claim: claim_with_reference)

        expect { service }.not_to change(claim, :reference)
      end
    end

    context "when claim status has not changed" do
      it "does not send any emails" do
        submitted_claim = create(:claim, status: :draft, school:)
        service = described_class.call(claim: submitted_claim)

        expect(service).to be_nil
        expect(UserMailer).not_to receive(:with).with(any_args)
      end
    end

    context "when claim reference is already taken" do
      it "creates a draft claim with a new reference" do
        create(:claim, reference: "123")
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123, 456)

        expect { draft_service }.to change(claim, :reference).from(nil).to("456")

        expect(claim.status).to eq("draft")
      end
    end
  end
end

require "rails_helper"

describe Claims::Submit do
  subject(:submit_service) { described_class.call(claim:, claim_params:, user:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal, school:) }

  let(:claim_params) { { status: :submitted, submitted_at: } }
  let(:submitted_at) { Time.new("2024-03-04 10:32:04 UTC") }
  let(:school) { create(:claims_school, urn: "1234") }
  let(:user) { create(:claims_user) }

  it_behaves_like "a service object" do
    let(:params) { { claim:, claim_params:, user: } }
  end

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
        service = described_class.call(claim: claim_with_reference, claim_params:, user:)

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
      let(:claim_params) { { status: :draft } }

      it "submits the claim" do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        expect { submit_service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("draft")
        expect(claim.submitted_at).to be_nil
      end
    end

    context "when claim params are not submitted" do
      let(:claim_params) { { status: :draft } }

      it "does not send an email" do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        expect { submit_service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("draft")
        expect(claim.submitted_at).to be_nil

        expect(submit_service).to be_nil
      end
    end

    context "when claim params are submitted" do
      let(:claim_params) { { status: :submitted, submitted_at: } }

      it "sends an email" do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        expect { submit_service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("submitted")
        expect(claim.submitted_at).to eq(submitted_at)

        expect(submit_service.arguments.first).to eq("UserMailer")
        expect(submit_service.arguments.second).to eq("claim_submitted_notification")
      end
    end

    context "when claim params status is internal" do
      let(:claim_params) { { status: :internal } }

      it "does not send an email or call send_claim_submitted_notification_email " do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        expect { submit_service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("internal")
        expect(claim.submitted_at).to be_nil
        expect(submit_service).to be_nil
      end
    end

    context "when the current user is a support user" do
      before do
        create(:claims_user, email: "babagoli@gmail.com", user_memberships: [create(:user_membership, organisation: school)])
        create(:claims_user, email: "email@gmail.com", user_memberships: [create(:user_membership, organisation: school)])
      end

      let(:claim_params) { { status: :draft } }
      let(:support_user) { create(:claims_support_user, :colin) }

      let(:service) { described_class.call(claim:, claim_params:, user: support_user) }

      it "sends an email using the send_claim_created_support_notification_email to each user of a school" do
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123)

        mailer_stub = class_double("mailer")
        expect(UserMailer).to receive(:with).with(any_args).twice.and_return(mailer_stub)
        expect(mailer_stub).to receive(:claim_created_support_notification).twice.and_return(mailer_stub)
        expect(mailer_stub).to receive(:deliver_later).twice

        expect { service }.to change(claim, :reference).from(nil).to("123")
        expect(claim.status).to eq("draft")
      end
    end
  end
end

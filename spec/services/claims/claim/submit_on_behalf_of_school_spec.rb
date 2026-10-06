require "rails_helper"

describe Claims::Claim::SubmitOnBehalfOfSchool do
  subject(:submit_service) { described_class.call(claim:, support_user:) }

  let(:support_user) { create(:claims_support_user) }
  let(:past_claim_window) { create(:claim_window, :historic) }
  let(:current_claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }
  let(:school) { create(:claims_school) }
  let(:claim) { build(:claim, reference: nil, status: :internal_draft, school:, claim_window: past_claim_window) }

  before { current_claim_window }

  it_behaves_like "a service object" do
    let(:params) { { claim:, support_user: } }
  end

  describe "#call" do
    it "submits the claim on behalf of the school" do
      submitted_at = Time.zone.local(2024, 3, 4, 10, 32, 4)
      allow(Time).to receive(:current).and_return(submitted_at)

      expect { submit_service }.to change(Claims::Claim, :count).by(1)

      expect(claim).to be_persisted
      expect(claim.status).to eq("submitted")
      expect(claim.submitted_at).to eq(submitted_at)
      expect(claim.submitted_by).to eq(support_user)
      expect(claim.reference).to be_present
    end

    it "keeps the selected claim window even when another claim window is open" do
      submit_service

      expect(claim.reload.claim_window).to eq(past_claim_window)
    end

    it "does not email the school or the support user" do
      expect { submit_service }.not_to have_enqueued_mail
    end

    it "keeps the reference of a claim that already has one" do
      claim.reference = "12345678"

      expect { submit_service }.not_to change(claim, :reference)
      expect(claim.reload.reference).to eq("12345678")
    end

    it "does not mark the claim as paid by default" do
      submit_service

      expect(claim.reload).to have_attributes(status: "submitted", date_paid: nil, paid_to_la: nil, paid_notification_sent_at: nil)
    end

    context "when the claim is paid" do
      subject(:submit_service) do
        described_class.call(claim:, support_user:, status: :paid, paid_to_la: false, date_paid:)
      end

      let(:date_paid) { Time.zone.local(2024, 12, 20) }

      it "creates the claim as paid with the payment details" do
        expect { submit_service }.to change(Claims::Claim, :count).by(1)

        expect(claim.reload).to have_attributes(
          status: "paid",
          date_paid:,
          paid_to_la: false,
          submitted_by: support_user,
          claim_window: past_claim_window,
        )
        expect(claim.reference).to be_present
        expect(claim.submitted_at).to be_present
      end

      it "records the notification as already sent so the school is not emailed" do
        submit_service

        expect(claim.reload.paid_notification_sent_at).to be_present
        expect(Claims::Claim.awaiting_paid_notification).not_to include(claim)
      end

      it "does not email the school or the support user" do
        expect { submit_service }.not_to have_enqueued_mail
      end

      it "keeps the selected claim window even when another claim window is open" do
        submit_service

        expect(claim.reload.claim_window).to eq(past_claim_window)
      end

      context "when paid to a local authority" do
        subject(:submit_service) do
          described_class.call(claim:, support_user:, status: :paid, paid_to_la: true, date_paid:)
        end

        it "records the payment as paid to the local authority" do
          submit_service

          expect(claim.reload.paid_to_la).to be(true)
        end
      end

      context "when the date paid is missing" do
        let(:date_paid) { nil }

        it "raises and does not create the claim" do
          expect { submit_service }.to raise_error(ArgumentError, "date_paid is required for a paid claim")
          expect(Claims::Claim.count).to eq(0)
        end
      end

      context "when who the claim was paid to is missing" do
        subject(:submit_service) { described_class.call(claim:, support_user:, status: :paid, paid_to_la: nil, date_paid:) }

        it "raises and does not create the claim" do
          expect { submit_service }.to raise_error(ArgumentError, "paid_to_la is required for a paid claim")
          expect(Claims::Claim.count).to eq(0)
        end
      end

      context "when the claim is invalid" do
        let(:claim) { build(:claim, school:, claim_window: past_claim_window, provider: nil) }

        it "raises and does not create the claim" do
          expect { submit_service }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Claims::Claim.count).to eq(0)
        end
      end
    end

    context "when the status is given as a string" do
      subject(:submit_service) { described_class.call(claim:, support_user:, status: "submitted") }

      it "submits the claim" do
        submit_service

        expect(claim.reload.status).to eq("submitted")
      end
    end

    context "when the status is not submitted or paid" do
      subject(:submit_service) { described_class.call(claim:, support_user:, status: :sampling_in_progress) }

      it "raises and does not create the claim" do
        expect { submit_service }.to raise_error(ArgumentError, "status must be submitted or paid")
        expect(Claims::Claim.count).to eq(0)
      end
    end

    context "when the claim is invalid" do
      let(:claim) { build(:claim, school:, claim_window: past_claim_window, provider: nil) }

      it "raises and does not create the claim" do
        expect { submit_service }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Claims::Claim.count).to eq(0)
      end
    end
  end
end

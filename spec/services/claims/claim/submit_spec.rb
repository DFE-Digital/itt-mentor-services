require "rails_helper"

describe Claims::Claim::Submit do
  subject(:submit_service) { described_class.call(claim:, user:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal_draft, school:) }

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
        .and(have_enqueued_mail(Claims::UserMailer, :claim_submitted_notification).once)

      expect(claim.status).to eq("submitted")
      expect(claim.submitted_at).to eq(submitted_at)
    end

    context "when claim has a reference already" do
      it "does not change the existing reference" do
        claim_with_reference = create(:claim, reference: "123")
        service = described_class.call(claim: claim_with_reference, user:)

        expect { service }.to not_change(claim, :reference)
          .and(not_have_enqueued_mail(Claims::UserMailer, :claim_submitted_notification))
      end
    end

    context "when claim status has not changed" do
      it "does not send any emails" do
        submitted_claim = create(:claim, status: :submitted, school:)
        service = described_class.call(claim: submitted_claim, user:)

        expect { service }.to not_change(claim, :reference)
          .and(not_have_enqueued_mail(Claims::UserMailer, :claim_submitted_notification))

        expect(service).to be_nil
      end
    end

    context "when claim reference is already taken" do
      it "submits the claim with a new reference" do
        allow(Time).to receive(:current).and_return(submitted_at)
        create(:claim, reference: "123")
        allow(SecureRandom).to receive(:random_number).with(99_999_999).and_return(123, 456)

        expect { submit_service }.to change(claim, :reference).from(nil).to("456")
          .and(have_enqueued_mail(Claims::UserMailer, :claim_submitted_notification).once)

        expect(claim.status).to eq("submitted")
        expect(claim.submitted_at).to eq(submitted_at)
      end
    end

    context "when there is a current claim window" do
      it "assigns the claim to the current claim window" do
        current_claim_window = Claims::ClaimWindow.current
        past_claim_window = create(:claim_window, :historic)
        claim.update!(claim_window: past_claim_window)

        expect { submit_service }.to change(claim, :claim_window).from(past_claim_window).to(current_claim_window)
      end
    end

    context "when there is no current claim window" do
      before do
        allow(Claims::ClaimWindow).to receive(:current).and_return(nil)
      end

      it "does not change the claim window" do
        past_claim_window = create(:claim_window, :historic)
        claim.update!(claim_window: past_claim_window)

        expect { submit_service }.to not_change(claim, :claim_window)
      end
    end
  end
end

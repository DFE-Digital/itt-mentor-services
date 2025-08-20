require "rails_helper"

describe Claims::ClaimPolicy do
  subject(:claim_policy) { described_class }

  let(:user) { build(:claims_user) }
  let(:school) { create(:claims_school, eligibilities: [eligibility]) }

  let(:internal_draft_claim) { build(:claim, school:) }
  let(:draft_claim) { build(:claim, :draft, school:) }
  let(:submitted_claim) { create(:claim, :submitted) }

  let(:payment_in_progress_claim) { create(:claim, :submitted, status: :payment_in_progress) }
  let(:payment_information_requested_claim) do
    create(:claim, :submitted, status: :payment_information_requested)
  end
  let(:payment_information_sent_claim) { create(:claim, :submitted, status: :payment_information_sent) }
  let(:paid_claim) { create(:claim, :submitted, status: :paid) }
  let(:payment_not_approved_claim) { create(:claim, :submitted, status: :payment_not_approved) }

  let(:sampling_in_progress_claim) { create(:claim, :submitted, status: :sampling_in_progress) }
  let(:sampling_provider_not_approved_claim) do
    create(:claim, :submitted, status: :sampling_provider_not_approved)
  end
  let(:sampling_not_approved_claim) { create(:claim, :submitted, status: :sampling_not_approved) }

  let(:clawback_requested_claim) { create(:claim, :submitted, status: :clawback_requested) }
  let(:clawback_in_progress_claim) { create(:claim, :submitted, status: :clawback_in_progress) }
  let(:clawback_complete_claim) { create(:claim, :submitted, status: :clawback_complete) }

  let(:claim_window) { Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: 2.days.ago, ends_on: 2.days.from_now }) }
  let(:current_claim_window) { Claims::ClaimWindow.current }
  let(:eligibility) { build(:eligibility, claim_window: current_claim_window) }

  before do
    claim_window.save!(validate: false)
  end

  permissions :edit? do
    context "when user has an internal draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_draft_claim)
      end
    end

    context "when the user has a draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, draft_claim)
      end
    end

    context "when the user has a submitted claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end

    context "when the user has a payment in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_in_progress_claim)
      end
    end

    context "when the user has a payment information requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_requested_claim)
      end
    end

    context "when the user has a payment information sent claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_sent_claim)
      end
    end

    context "when the user has a paid claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, paid_claim)
      end
    end

    context "when the user has a payment not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_not_approved_claim)
      end
    end

    context "when the user has a sampling in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_in_progress_claim)
      end
    end

    context "when the user has a sampling provider not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_provider_not_approved_claim)
      end
    end

    context "when the user has a sampling not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_not_approved_claim)
      end
    end

    context "when the user has a clawback requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_requested_claim)
      end
    end

    context "when the user has a clawback in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_in_progress_claim)
      end
    end

    context "when the user has a clawback complete claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_complete_claim)
      end
    end

    context "when the claim's school is not eligible for the claim window" do
      let(:school) { build(:claims_school) }

      it "denies access" do
        expect(claim_policy).not_to permit(user, internal_draft_claim)
      end
    end
  end

  permissions :update?, :rejected?, :submit? do
    context "when user has an internal draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_draft_claim)
      end
    end

    context "when user has a draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, draft_claim)
      end
    end

    context "when user has a submitted claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end

    context "when the user has a payment in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_in_progress_claim)
      end
    end

    context "when the user has a payment information requested claim" do
      let(:support_user) { create(:claims_support_user) }

      it "denies access" do
        expect(claim_policy).not_to permit(support_user, submitted_claim)
      end
    end
  end

  permissions :rejected? do
    context "when user has an new claim (unsaved)" do
      it "grants access" do
        expect(claim_policy).to permit(user, Claims::Claim.new(school:))
      end
    end

    context "when user has an internal draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_draft_claim)
      end
    end

    context "when the user has a payment information sent claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_sent_claim)
      end
    end

    context "when the user has a paid claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, paid_claim)
      end
    end

    context "when the user has a payment not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_not_approved_claim)
      end
    end

    context "when the user has a sampling in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_in_progress_claim)
      end
    end

    context "when the user has a sampling provider not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_provider_not_approved_claim)
      end
    end

    context "when the user has a sampling not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_not_approved_claim)
      end
    end

    context "when the user has a clawback requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_requested_claim)
      end
    end

    context "when the user has a clawback in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_in_progress_claim)
      end
    end

    context "when the user has a clawback complete claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_complete_claim)
      end
    end
  end

  permissions :confirmation? do
    context "when user has a submitted claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, submitted_claim)
      end
    end

    context "when user has an internal draft claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, internal_draft_claim)
      end
    end

    context "when user has a draft claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, draft_claim)
      end
    end

    context "when the user has a payment in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_in_progress_claim)
      end
    end

    context "when the user has a payment information requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_requested_claim)
      end
    end

    context "when the user has a payment information sent claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_sent_claim)
      end
    end

    context "when the user has a paid claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, paid_claim)
      end
    end

    context "when the user has a payment not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_not_approved_claim)
      end
    end

    context "when the user has a sampling in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_in_progress_claim)
      end
    end

    context "when the user has a sampling provider not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_provider_not_approved_claim)
      end
    end

    context "when the user has a sampling not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_not_approved_claim)
      end
    end

    context "when the user has a clawback requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_requested_claim)
      end
    end

    context "when the user has a clawback in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_in_progress_claim)
      end
    end

    context "when the user has a clawback complete claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_complete_claim)
      end
    end
  end

  permissions :check? do
    context "when user has a draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, draft_claim)
      end
    end

    context "when user has an internal draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_draft_claim)
      end
    end

    context "when user has a submitted claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end

    context "when the user has a payment in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_in_progress_claim)
      end
    end

    context "when the user has a payment information requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_requested_claim)
      end
    end

    context "when the user has a payment information sent claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_information_sent_claim)
      end
    end

    context "when the user has a paid claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, paid_claim)
      end
    end

    context "when the user has a payment not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, payment_not_approved_claim)
      end
    end

    context "when the user has a sampling in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_in_progress_claim)
      end
    end

    context "when the user has a sampling provider not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_provider_not_approved_claim)
      end
    end

    context "when the user has a sampling not approved claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, sampling_not_approved_claim)
      end
    end

    context "when the user has a clawback requested claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_requested_claim)
      end
    end

    context "when the user has a clawback in progress claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_in_progress_claim)
      end
    end

    context "when the user has a clawback complete claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_complete_claim)
      end
    end
  end

  permissions :invalid_provider? do
    context "when the claim is invalid provider and created by the user" do
      let(:claim) { build(:claim, status: :invalid_provider, created_by: user) }

      it "grants access" do
        expect(claim_policy).to permit(user, claim)
      end
    end

    context "when the claim is invalid provider and created by another user" do
      let(:other_user) { build(:claims_user) }
      let(:claim) { build(:claim, status: :invalid_provider, created_by: other_user) }

      it "denies access" do
        expect(claim_policy).not_to permit(user, claim)
      end
    end

    context "when the user is a support user" do
      let(:support_user) { build(:claims_support_user) }
      let(:claim) { build(:claim, status: :invalid_provider, created_by: user) }

      it "grants access" do
        expect(claim_policy).to permit(support_user, claim)
      end
    end
  end

  permissions :destroy? do
    context "when the claim is in draft status" do
      it "grants access" do
        expect(claim_policy).to permit(user, draft_claim)
      end
    end

    context "when the claim is invalid provider" do
      let(:claim) { build(:claim, status: :invalid_provider, created_by: user) }

      it "grants access" do
        expect(claim_policy).to permit(user, claim)
      end
    end

    context "when the claim is submitted and user is a support user" do
      let(:user) { build(:claims_support_user) }

      it "grants access" do
        expect(claim_policy).to permit(user, submitted_claim)
      end
    end

    context "when the claim is submitted and user is not a support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end
  end
end

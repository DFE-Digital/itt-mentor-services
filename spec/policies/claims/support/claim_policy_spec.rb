require "rails_helper"

describe Claims::Support::ClaimPolicy do
  subject(:claim_policy) { described_class }

  let(:user) { build(:claims_user) }
  let(:support_user) { build(:claims_support_user) }
  let(:internal_draft_claim) { build(:claim) }
  let(:draft_claim) { build(:claim, :draft) }
  let(:submitted_claim) { build(:claim, :submitted) }

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
  let(:clawback_requires_approval_claim) { create(:claim, :submitted, status: :clawback_requires_approval) }

  before do
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: 2.days.ago, ends_on: 2.days.from_now }).save!(validate: false)
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
  end

  permissions :update? do
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

  permissions :submit? do
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

    context "when user has a subbitted claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end

    context "when user is a support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(support_user, submitted_claim)
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

  permissions :rejected? do
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

    context "when user is a support user" do
      it "grants access" do
        expect(claim_policy).to permit(support_user, draft_claim)
      end
    end

    context "when user has a subbitted claim" do
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

  permissions :draft? do
    context "when user has an internal draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(support_user, internal_draft_claim)
      end
    end

    context "when user has a draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(support_user, draft_claim)
      end
    end

    context "when user has a submitted claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(support_user, submitted_claim)
      end
    end

    context "when user is not a support user" do
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
  end

  permissions :download_csv? do
    context "when user is a support user" do
      it "grants access" do
        expect(claim_policy).to permit(support_user)
      end
    end

    context "when user is not support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(user)
      end
    end
  end

  permissions :destroy? do
    context "when user has a draft claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, draft_claim)
      end
    end

    context "when user has a submitted claim" do
      it "grants access" do
        expect(claim_policy).to permit(support_user, submitted_claim)
      end
    end

    context "when user is not support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, submitted_claim)
      end
    end
  end

  permissions :approve_clawback? do
    context "when user is not a support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, clawback_requires_approval_claim)
      end
    end

    context "when user is a support user" do
      context "when the claim does not have the status clawback requires approval" do
        it "denies access" do
          expect(claim_policy).not_to permit(support_user, clawback_requested_claim)
        end
      end

      context "when the support user is the same user who requested the clawback" do
        before do
          clawback_requires_approval_claim.update!(clawback_requested_by: support_user)
        end

        it "denies access" do
          expect(claim_policy).not_to permit(support_user, clawback_requires_approval_claim)
        end
      end

      context "when the support user is not the same user who requested the clawback" do
        it "grants access" do
          expect(claim_policy).to permit(support_user, clawback_requires_approval_claim)
        end
      end
    end
  end
end

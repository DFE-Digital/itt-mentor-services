require "rails_helper"

describe Claims::Support::ClaimPolicy do
  subject(:claim_policy) { described_class }

  let(:user) { build(:claims_user) }
  let(:support_user) { build(:claims_support_user) }
  let(:internal_draft_claim) { build(:claim) }
  let(:draft_claim) { build(:claim, :draft) }
  let(:submitted_claim) { build(:claim, :submitted) }

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
end

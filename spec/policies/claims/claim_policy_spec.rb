require "rails_helper"

describe Claims::ClaimPolicy do
  subject(:claim_policy) { described_class }

  let(:user) { build(:claims_user) }
  let(:support_user) { build(:claims_support_user) }
  let(:internal_claim) { build(:claim) }
  let(:draft_claim) { build(:claim, :draft) }
  let(:submitted_claim) { build(:claim, :submitted) }

  permissions :edit? do
    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_claim)
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
    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_claim)
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
    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_claim)
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

  permissions :confirm? do
    context "when user has a submitted claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, submitted_claim)
      end
    end

    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).not_to permit(user, internal_claim)
      end
    end

    context "when user has a draft claim" do
      it "denies access" do
        expect(claim_policy).not_to permit(user, draft_claim)
      end
    end

    context "when user is a support user" do
      it "denies access" do
        expect(claim_policy).not_to permit(support_user, submitted_claim)
      end
    end
  end

  permissions :draft? do
    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).to permit(support_user, internal_claim)
      end
    end

    context "when user has a draft claim" do
      it "grants access" do
        expect(claim_policy).not_to permit(support_user, draft_claim)
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

    context "when user has an internal claim" do
      it "grants access" do
        expect(claim_policy).to permit(user, internal_claim)
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

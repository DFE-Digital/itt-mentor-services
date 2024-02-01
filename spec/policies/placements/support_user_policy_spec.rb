require "rails_helper"

describe Placements::SupportUserPolicy do
  subject { described_class }

  let(:support_user_1) { create(:placements_support_user) }
  let(:support_user_2) { create(:placements_support_user) }

  permissions :destroy? do
    it "denies access current_user is the support_user" do
      expect(subject).not_to permit(support_user_1, support_user_1)
    end

    it "grants access current_user is not the support_user" do
      expect(subject).to permit(support_user_1, support_user_2)
    end
  end
end

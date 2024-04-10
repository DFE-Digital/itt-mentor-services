require "rails_helper"

describe Placements::PartnershipPolicy do
  subject(:placements_partnership_policy) { described_class }

  let(:placements_school) { create(:placements_school) }
  let(:placements_provider) { create(:placements_provider) }
  let!(:placements_partnership) do
    create(
      :placements_partnership,
      school: placements_school,
      provider: placements_provider,
    )
  end

  permissions :destroy?, :remove? do
    context "when the user is associated with the partnership provider" do
      it "grants access" do
        current_user = create(:placements_user, providers: [placements_provider])
        expect(placements_partnership_policy).to permit(current_user, placements_partnership)
      end
    end

    context "when the user is associated with the partnership school" do
      it "grants access" do
        current_user = create(:placements_user, schools: [placements_school])
        expect(placements_partnership_policy).to permit(current_user, placements_partnership)
      end
    end

    context "when the user is not associated with either the partnership school or provider" do
      it "denies access" do
        current_user = create(:placements_user)
        expect(placements_partnership_policy).not_to permit(current_user, placements_partnership)
      end
    end
  end
end

require "rails_helper"

describe Claims::Support::Claims::ClawbackPolicy do
  subject { described_class }

  let(:support_user) { build(:claims_support_user) }

  permissions :new? do
    it { is_expected.to permit(support_user, Claims::Payment) }
  end

  permissions :create? do
    context "when there are clawback requested claims" do
      before do
        create(:claim, :submitted, status: :clawback_requested)
      end

      it { is_expected.to permit(support_user, Claims::Payment) }
    end

    context "when there are no clawback requested claims" do
      it { is_expected.not_to permit(support_user, Claims::Payment) }
    end
  end
end

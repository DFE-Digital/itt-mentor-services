# == Schema Information
#
# Table name: claim_activities
#
#  id          :uuid             not null, primary key
#  action      :string
#  record_type :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_id   :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_claim_activities_on_record   (record_type,record_id)
#  index_claim_activities_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Claims::ClaimActivity, type: :model do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:action).in_array(described_class.actions.keys) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:record) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true).allow_nil }
  end

  describe "#claims_by_provider" do
    context "when the record responds to claims" do
      let(:provider) { build(:claims_provider) }
      let(:claim_1) { build(:claim, provider: provider, reference: 11_111_111) }
      let(:claim_2) { build(:claim, provider: provider, reference: 22_222_222) }
      let(:provider_sampling) { build(:provider_sampling, provider:) }
      let(:claim_activity) { create(:claim_activity, action: :sampling_uploaded, record: provider_sampling) }

      before do
        create(:claims_provider_sampling_claim, claim: claim_1, provider_sampling: provider_sampling)
        create(:claims_provider_sampling_claim, claim: claim_2, provider_sampling: provider_sampling)
      end

      it "returns the claims grouped by provider" do
        expect(claim_activity.claims_by_provider).to eq({
          provider => [claim_1, claim_2],
        })
      end
    end

    context "when the record does not respond to claims" do
      it "returns an empty array" do
        claim_activity = create(:claim_activity, action: :sampling_uploaded, record: create(:claim))

        expect(claim_activity.claims_by_provider).to eq({})
      end
    end
  end
end

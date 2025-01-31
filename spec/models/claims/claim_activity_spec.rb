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
end

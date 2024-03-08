# == Schema Information
#
# Table name: user_memberships
#
#  id                :uuid             not null, primary key
#  organisation_type :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :uuid             not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_memberships_on_organisation                      (organisation_type,organisation_id)
#  index_user_memberships_on_user_id                      (user_id)
#  index_user_memberships_on_user_id_and_organisation_id  (user_id,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe UserMembership, type: :model do
  subject(:test_membership) { create(:user_membership) }

  context "with associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organisation) }
  end

  context "with validations" do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:organisation_id) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:organisation) }
    it { is_expected.to delegate_method(:placements_service).to(:organisation) }
  end
end

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

  context "with validations" do
    it do
      expect(test_membership).to validate_uniqueness_of(:user).scoped_to(:organisation_id)
    end
  end

  context "with associations" do
    it do
      expect(test_membership).to belong_to(:user)
      expect(test_membership).to belong_to(:organisation)
    end
  end
end

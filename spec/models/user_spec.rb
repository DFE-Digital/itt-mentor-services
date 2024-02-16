# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  dfe_sign_in_uid   :string
#  discarded_at      :datetime
#  email             :string           not null
#  first_name        :string           not null
#  last_name         :string           not null
#  last_signed_in_at :datetime
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_discarded_at_and_email  (type,discarded_at,email)
#  index_users_on_type_and_email                   (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject(:test_user) { build(:user) }

  context "with associations" do
    it { is_expected.to have_many(:user_memberships).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:type).case_insensitive }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email) }
    it { is_expected.to allow_value("name@example.com").for(:email) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe "scopes" do
    describe "default" do
      context "when the list of users includes a soft deleted (discarded) user" do
        it "returns only kept (not discarded) users" do
          create(:claims_user, :discarded)
          create(:placements_user, :discarded)
          create(:claims_support_user, :discarded)
          create(:placements_support_user, :discarded)

          kept_claims_user = create(:claims_user)
          kept_placements_user = create(:placements_user)
          kept_claims_support_user = create(:claims_support_user)
          kept_placements_support_user = create(:placements_support_user)

          expect(described_class.all).to match_array([
            kept_claims_user,
            kept_placements_user,
            kept_claims_support_user,
            kept_placements_support_user,
          ])
        end
      end
    end
  end

  describe "#support_user?" do
    it "returns false" do
      expect(test_user.support_user?).to eq(false)
    end
  end

  describe "#full_name" do
    it "returns the users full name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end
end

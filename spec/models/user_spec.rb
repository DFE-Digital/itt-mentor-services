# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  context "associations" do
    it { should have_many(:memberships) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it do
      is_expected.to validate_uniqueness_of(:email).scoped_to(
        :type,
      ).case_insensitive
    end
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:type) }
  end

  context "scopes" do
    describe "#claims" do
      it "only returns users of type Claims::User" do
        claims_user = create(:claims_user)
        create(:claims_support_user)
        create(:placements_user)
        create(:placements_support_user)

        expect(described_class.claims).to contain_exactly(claims_user)
      end
    end

    describe "#placements" do
      it "only returns users of type Placements::User" do
        create(:claims_user)
        create(:claims_support_user)
        create(:placements_support_user)
        placements_user = create(:placements_user)

        expect(described_class.placements).to contain_exactly(placements_user)
      end
    end
  end

  describe "#is_support_user?" do
    it "returns false" do
      expect(subject.is_support_user?).to eq(false)
    end
  end
end

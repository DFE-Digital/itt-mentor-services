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
#  index_users_on_discarded_at    (discarded_at)
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  context "associations" do
    it { should have_many(:memberships).dependent(:destroy) }
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

  describe "#support_user?" do
    it "returns false" do
      expect(subject.support_user?).to eq(false)
    end
  end
end

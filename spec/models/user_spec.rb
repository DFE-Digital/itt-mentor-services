# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  email        :string           not null
#  first_name   :string           not null
#  last_name    :string           not null
#  service      :enum             not null
#  support_user :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_service_and_email  (service,email) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject { create(:user) }

  context "associations" do
    it do
      should have_many(:memberships)
      should have_many(:schools).through(:memberships).source(:organisation)
      should have_many(:providers).through(:memberships).source(:organisation)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it do
      is_expected.to validate_uniqueness_of(:email).scoped_to(
        :service,
      ).case_insensitive
    end
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end
end

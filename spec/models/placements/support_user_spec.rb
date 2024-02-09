# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  dfe_sign_in_uid   :string
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
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Placements::SupportUser do
  context "with validations" do
    subject { build(:placements_support_user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:type).case_insensitive }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email).with_message(:invalid_support_email) }
    it { is_expected.not_to allow_value("name@example.com").for(:email).with_message(:invalid_support_email) }
    it { is_expected.not_to allow_value("name@education.gov.ukk").for(:email).with_message(:invalid_support_email) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe "#support_user?" do
    it "returns true" do
      expect(described_class.new.support_user?).to eq(true)
    end
  end

  describe "#service" do
    it "returns :placements" do
      expect(described_class.new.service).to eq(:placements)
    end
  end
end

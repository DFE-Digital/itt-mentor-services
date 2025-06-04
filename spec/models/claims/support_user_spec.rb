# == Schema Information
#
# Table name: users
#
#  id                        :uuid             not null, primary key
#  dfe_sign_in_uid           :string
#  discarded_at              :datetime
#  email                     :string           not null
#  first_name                :string           not null
#  last_name                 :string           not null
#  last_signed_in_at         :datetime
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  selected_academic_year_id :uuid
#
# Indexes
#
#  index_users_on_selected_academic_year_id        (selected_academic_year_id)
#  index_users_on_type_and_discarded_at_and_email  (type,discarded_at,email)
#  index_users_on_type_and_email                   (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Claims::SupportUser do
  describe "associations" do
    it { is_expected.to have_many(:assigned_claims).class_name("Claims::Claim") }
    it { is_expected.to have_many(:onboarded_schools).class_name("Claims::School") }
  end

  context "with validations" do
    subject { build(:claims_support_user) }

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
      expect(described_class.new.support_user?).to be(true)
    end
  end

  describe "#service" do
    it "returns :claims" do
      expect(described_class.new.service).to eq(:claims)
    end
  end
end

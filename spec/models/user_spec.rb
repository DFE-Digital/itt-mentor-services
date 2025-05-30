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

RSpec.describe User, type: :model do
  subject(:test_user) { build(:user) }

  context "with associations" do
    it { is_expected.to have_many(:user_memberships).dependent(:destroy) }
  end

  describe "normalizations" do
    it { is_expected.to normalize(:first_name).from("  Jane  ").to("Jane") }
    it { is_expected.to normalize(:last_name).from("  Doe  ").to("Doe") }
    it { is_expected.to normalize(:email).from("  Jane.Doe@Example.com  ").to("jane.doe@example.com") }
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

          expect(described_class.all).to contain_exactly(kept_claims_user, kept_placements_user, kept_claims_support_user, kept_placements_support_user)
        end
      end
    end

    describe "#order_by_full_name" do
      it "returns the users ordered by full name" do
        user1 = create(:claims_user, first_name: "Anne", last_name: "Smith")
        user2 = create(:placements_user, first_name: "Anne", last_name: "Doe")
        user3 = create(:placements_support_user, first_name: "John", last_name: "Doe")

        expect(described_class.order_by_full_name).to eq(
          [user2, user1, user3],
        )
      end
    end
  end

  describe "#support_user?" do
    it "returns false" do
      expect(test_user.support_user?).to be(false)
    end
  end

  describe "#full_name" do
    it "returns the users full name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#service" do
    it "returns the service name" do
      user = build(:claims_user)
      expect(user.service).to eq(:claims)
    end
  end
end

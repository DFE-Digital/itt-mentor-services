# == Schema Information
#
# Table name: mentors
#
#  id         :uuid             not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  trn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_mentors_on_trn  (trn) UNIQUE
#
require "rails_helper"

RSpec.describe Mentor, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:schools).through(:mentor_memberships) }

    it { is_expected.to have_many(:placement_mentor_joins).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:placements).through(:placement_mentor_joins) }
  end

  describe "normalisations" do
    it { is_expected.to normalize(:trn).from(" 1234567 ").to("1234567") }
  end

  context "with validations" do
    subject { build(:mentor) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:trn).with_message("Enter a teacher reference number (TRN)") }

    it "allows only TRNs that are seven numeric characters long" do
      mentor_with_alpha_trn = build(:mentor, trn: "a12345b")
      expect(mentor_with_alpha_trn.valid?).to be false
      expect(mentor_with_alpha_trn.errors.messages[:trn]).to include "Enter a 7 digit teacher reference number (TRN)"

      mentor_with_too_few_chars = build(:mentor, trn: "123")
      expect(mentor_with_too_few_chars.valid?).to be false
      expect(mentor_with_too_few_chars.errors.messages[:trn]).to include "Enter a 7 digit teacher reference number (TRN)"

      mentor_with_too_many_chars = build(:mentor, trn: "123456789")
      expect(mentor_with_too_many_chars.valid?).to be false
      expect(mentor_with_too_many_chars.errors.messages[:trn]).to include "Enter a 7 digit teacher reference number (TRN)"
    end
  end

  context "with scopes" do
    describe "#order_by_full_name" do
      it "returns the mentors ordered by full name" do
        mentor1 = create(:mentor, first_name: "Anne", last_name: "Smith")
        mentor2 = create(:mentor, first_name: "Anne", last_name: "Doe")
        mentor3 = create(:mentor, first_name: "John", last_name: "Doe")

        expect(described_class.order_by_full_name).to eq(
          [mentor2, mentor1, mentor3],
        )
      end
    end
  end

  describe "#full_name" do
    it "returns the mentors full name" do
      mentor = build(:mentor, first_name: "Jane", last_name: "Doe")
      expect(mentor.full_name).to eq("Jane Doe")
    end
  end
end

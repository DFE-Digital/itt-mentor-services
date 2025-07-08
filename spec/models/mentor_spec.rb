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

    describe "#trained_in_academic_year" do
      subject(:trained_in_academic_year) do
        described_class.trained_in_academic_year(current_claim_window.academic_year)
      end

      let(:historic_claim_window) { build(:claim_window, :historic) }
      let(:current_claim_window) { build(:claim_window, :current) }

      let(:current_trained_mentor) { build(:mentor, first_name: "Anne", last_name: "Smith") }
      let(:historic_trained_mentor) { build(:mentor, first_name: "Anne", last_name: "Doe") }
      let(:untrained_mentor) { create(:mentor, first_name: "John", last_name: "Doe") }

      let(:historic_claim) { build(:claim, claim_window: historic_claim_window) }
      let(:current_claim) { build(:claim, claim_window: current_claim_window) }

      let(:historic_mentor_training) { create(:mentor_training, claim: historic_claim, mentor: historic_trained_mentor) }
      let(:current_mentor_training) { create(:mentor_training, claim: current_claim, mentor: current_trained_mentor) }

      before do
        historic_mentor_training
        current_mentor_training
      end

      it "returns mentors who trained in during the given academic year" do
        expect(trained_in_academic_year).to contain_exactly(current_trained_mentor)
      end
    end
  end

  describe "#full_name" do
    it "returns the mentors full name" do
      mentor = build(:mentor, first_name: "Jane", last_name: "Doe")
      expect(mentor.full_name).to eq("Jane Doe")
    end
  end

  describe "#full_name_possessive" do
    subject(:full_name_possessive) { mentor.full_name_possessive }

    context "when the mentor's full name ends with a 's'" do
      let(:mentor) { build(:mentor, first_name: "James", last_name: "Chess") }

      it "add a ' suffix to the mentor's full name" do
        expect(full_name_possessive).to eq("James Chess'")
      end
    end

    context "when the mentor's full name does not ens with a 's'" do
      let(:mentor) { create(:mentor, first_name: "James", last_name: "Chest") }

      it "add a ' suffix to the mentor's full name" do
        expect(full_name_possessive).to eq("James Chest's")
      end
    end
  end
end

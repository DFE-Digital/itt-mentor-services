# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  year_group  :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#  subject_id  :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#  index_placements_on_subject_id   (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (subject_id => subjects.id)
#
require "rails_helper"

RSpec.describe Placement, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_mentor_joins).dependent(:destroy) }
    it { is_expected.to have_many(:mentors).through(:placement_mentor_joins) }

    it { is_expected.to have_many(:placement_additional_subjects).class_name("Placements::PlacementAdditionalSubject").dependent(:destroy) }
    it { is_expected.to have_many(:additional_subjects).through(:placement_additional_subjects).class_name("Subject") }

    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:provider).optional }
    it { is_expected.to belong_to(:subject) }
  end

  describe "validations" do
    subject { build(:placement) }

    it { is_expected.to validate_presence_of(:school) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:has_child_subjects?).to(:subject).with_prefix(true).allow_nil }
  end

  describe "scopes" do
    describe "#order_by_subject_school_name" do
      it "returns the placements ordered by their associated schools name" do
        school_a = create(:placements_school, name: "Abbey School")
        school_b = create(:placements_school, name: "Bentley School")

        subject_a = create(:subject, name: "Art and design")
        subject_b = create(:subject, name: "Biology")

        placement_1 = create(:placement, school: school_b, subject: subject_a)
        placement_2 = create(:placement, school: school_a, subject: subject_b)
        placement_3 = create(:placement, school: school_b, subject: subject_b)

        expect(described_class.order_by_subject_school_name).to eq(
          [placement_1, placement_2, placement_3],
        )
      end
    end
  end

  describe "order_by_school_ids" do
    it "returns placements ordered by a given list of school ids" do
      school_1 = create(:placements_school)
      school_2 = create(:placements_school)
      school_3 = create(:placements_school)

      placement_1 = create(:placement, school: school_1)
      placement_2 = create(:placement, school: school_2)
      placement_3 = create(:placement, school: school_3)

      expect(
        described_class.order_by_school_ids(
          [school_2.id, school_3.id, school_1.id],
        ),
      ).to eq(
        [placement_2, placement_3, placement_1],
      )

      expect(
        described_class.order_by_school_ids(
          [school_3.id, school_2.id, school_1.id],
        ),
      ).to eq(
        [placement_3, placement_2, placement_1],
      )
    end
  end

  describe ".year_groups_as_options" do
    it "returns an array of OpenStruct objects with the year group value, name and description" do
      options = described_class.year_groups_as_options

      expect(options).to eq(
        [
          OpenStruct.new(value: "year_1", name: "Year 1", description: "5 to 6 years"),
          OpenStruct.new(value: "year_2", name: "Year 2", description: "6 to 7 years"),
          OpenStruct.new(value: "year_3", name: "Year 3", description: "7 to 8 years"),
          OpenStruct.new(value: "year_4", name: "Year 4", description: "8 to 9 years"),
          OpenStruct.new(value: "year_5", name: "Year 5", description: "9 to 10 years"),
          OpenStruct.new(value: "year_6", name: "Year 6", description: "10 to 11 years"),
        ],
      )
    end
  end
end

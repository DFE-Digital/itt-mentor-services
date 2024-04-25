# == Schema Information
#
# Table name: placements
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  status     :enum             default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid
#
# Indexes
#
#  index_placements_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Placement, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_mentor_joins).dependent(:destroy) }
    it { is_expected.to have_many(:mentors).through(:placement_mentor_joins) }

    it { is_expected.to have_many(:placement_subject_joins).dependent(:destroy) }
    it { is_expected.to have_many(:subjects).through(:placement_subject_joins) }

    it { is_expected.to belong_to(:school) }
  end

  describe "validations" do
    subject { build(:placement) }

    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "scopes" do
    describe "#order_by_subject_school_name" do
      it "returns the placements ordered by their associated schools name" do
        school_a = create(:placements_school, name: "Abbey School")
        school_b = create(:placements_school, name: "Bentley School")

        subject_a = create(:subject, name: "Art and design")
        subject_b = create(:subject, name: "Biology")

        placement_1 = create(:placement, school: school_b, subjects: [subject_a])
        placement_2 = create(:placement, school: school_a, subjects: [subject_b])
        placement_3 = create(:placement, school: school_b, subjects: [subject_b])
        placement_4 = create(:placement, school: school_b, subjects: [subject_a, subject_b])

        expect(described_class.order_by_subject_school_name).to eq(
          [placement_1, placement_4, placement_2, placement_3],
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: placements
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  status     :enum
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
    it { is_expected.to have_many(:placement_mentor_joins) }
    it { is_expected.to have_many(:mentors).through(:placement_mentor_joins) }

    it { is_expected.to have_many(:placement_subject_joins) }
    it { is_expected.to have_many(:subjects).through(:placement_subject_joins) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    it "validates that the start_date is before the end_date" do
      valid_placement = build(:placement, start_date: 1.month.from_now, end_date: 2.months.from_now)
      expect(valid_placement.valid?).to eq true

      invalid_placement = build(:placement, start_date: 2.months.from_now, end_date: 1.month.from_now)
      expect(invalid_placement.valid?).to eq false
      expect(invalid_placement.errors[:end_date]).to include("Enter an end date that comes after the start date")
    end
  end
end

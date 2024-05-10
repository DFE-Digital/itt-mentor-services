# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
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
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "validations" do
    subject { build(:placement) }

    it { is_expected.to validate_presence_of(:school) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true).allow_nil }
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
end

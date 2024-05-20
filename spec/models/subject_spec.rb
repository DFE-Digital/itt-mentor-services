# == Schema Information
#
# Table name: subjects
#
#  id                :uuid             not null, primary key
#  code              :string
#  name              :string           not null
#  subject_area      :enum
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_subject_id :uuid
#
# Indexes
#
#  index_subjects_on_parent_subject_id  (parent_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_subject_id => subjects.id)
#
require "rails_helper"

RSpec.describe Subject, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:parent_subject).optional }

    it { is_expected.to have_many(:child_subjects) }
    it { is_expected.to have_many(:placement_subject_joins).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:placements).through(:placement_subject_joins) }
  end

  describe "enums" do
    subject(:test_subject) { build(:subject) }

    it "defines the expected values" do
      expect(test_subject).to define_enum_for(:subject_area).with_values(primary: "primary", secondary: "secondary")
        .backed_by_column_of_type(:enum)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject_area) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "scopes" do
    describe "#order_by_name" do
      it "returns the subjects ordered by name" do
        subject1 = create(:subject, name: "English")
        subject2 = create(:subject, name: "Art")
        subject3 = create(:subject, name: "Science")

        expect(described_class.order_by_name).to eq(
          [subject2, subject1, subject3],
        )
      end
    end
  end
end

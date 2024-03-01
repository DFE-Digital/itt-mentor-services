# == Schema Information
#
# Table name: subjects
#
#  id           :uuid             not null, primary key
#  code         :string
#  name         :string           not null
#  subject_area :enum
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "rails_helper"

RSpec.describe Subject, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placement_subject_joins) }
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
end

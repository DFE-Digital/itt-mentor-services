# == Schema Information
#
# Table name: academic_years
#
#  id         :uuid             not null, primary key
#  starts_on  :date
#  ends_on    :date
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe AcademicYear, type: :model do
  subject(:academic_year) do
    build(:academic_year,
          name: "2023 to 2024",
          starts_on: Date.current,
          ends_on: Date.current + 1.day)
  end

  context "with associations" do
    it { is_expected.to have_many(:claim_windows) }
    it { is_expected.to have_many(:claims).through(:claim_windows) }
  end

  context "with validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }

    it { is_expected.to validate_comparison_of(:ends_on).is_greater_than_or_equal_to(:starts_on) }
  end
end

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
  describe "with validations" do
    subject(:academic_year) do
      build(:academic_year,
            name: "2023 to 2024",
            starts_on: Date.current,
            ends_on: Date.current + 1.day)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }
    it { is_expected.to validate_comparison_of(:ends_on).is_greater_than_or_equal_to(:starts_on) }
  end

  describe ".for_date" do
    let!(:existing_academic_year) do
      create(:academic_year,
             name: "2024 to 2025",
             starts_on: Date.new(2024, 9, 1),
             ends_on: Date.new(2025, 8, 31))
    end

    context "when date is within an existing academic year" do
      it "returns the existing academic year" do
        date = Date.new(2024, 11, 7)
        expect(described_class.for_date(date)).to eq(existing_academic_year)
      end
    end

    context "when date is not within an existing academic year" do
      it "creates a new academic year" do
        date = Date.new(2026, 10, 5)
        expect { described_class.for_date(date) }.to change(described_class, :count).by(1)
        new_academic_year = described_class.for_date(date)
        expect(new_academic_year.starts_on).to eq(Date.new(2026, 9, 1))
        expect(new_academic_year.ends_on).to eq(Date.new(2027, 8, 31))
        expect(new_academic_year.name).to eq("2026 to 2027")
      end
    end

    context "when start month is before September and academic year does not exist" do
      it "creates a new academic year starting the previous year" do
        date = Date.new(2026, 3, 14)
        new_academic_year = described_class.for_date(date)
        expect(new_academic_year.starts_on).to eq(Date.new(2025, 9, 1))
        expect(new_academic_year.ends_on).to eq(Date.new(2026, 8, 31))
        expect(new_academic_year.name).to eq("2025 to 2026")
      end
    end
  end
end

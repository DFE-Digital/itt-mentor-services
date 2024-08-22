# == Schema Information
#
# Table name: academic_years
#
#  id         :uuid             not null, primary key
#  ends_on    :date
#  name       :string
#  starts_on  :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Placements::AcademicYear, type: :model do
  describe ".current_academic_year" do
    let!(:current_academic_year) { create(:placements_academic_year, :current) }

    it "returns academic year for current date" do
      expect(described_class.current_academic_year).to eq(current_academic_year)
    end
  end

  describe "#next_academic_year" do
    let!(:current_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2024"),
             ends_on: Date.parse("31 August 2025"),
             name: "2024 to 2025")
    end
    let!(:next_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2025"),
             ends_on: Date.parse("31 August 2026"),
             name: "2025 to 2026")
    end

    it "returns next academic year" do
      expect(current_academic_year.next_academic_year).to eq(next_academic_year)
    end
  end

  describe "#previous_academic_year" do
    let!(:current_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2024"),
             ends_on: Date.parse("31 August 2025"),
             name: "2024 to 2025")
    end
    let!(:previous_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2023"),
             ends_on: Date.parse("31 August 2024"),
             name: "2023 to 2024")
    end

    it "returns previous academic year" do
      expect(current_academic_year.previous_academic_year).to eq(previous_academic_year)
    end
  end
end

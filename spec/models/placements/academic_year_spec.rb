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
  describe "associations" do
    it { is_expected.to have_many(:placements) }
  end

  describe ".current" do
    let!(:current_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2024"),
             ends_on: Date.parse("31 August 2025"),
             name: "2024 to 2025")
    end

    it "returns the academic year for the current date" do
      Timecop.travel(Date.parse("1 September 2024")) do
        expect(described_class.current).to eq(current_academic_year)
      end
    end
  end

  describe "#next" do
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

    it "returns the next academic year" do
      expect(current_academic_year.next).to eq(next_academic_year)
    end
  end

  context "when the next academic year does not exist" do
    let!(:current_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2030"),
             ends_on: Date.parse("31 August 2031"),
             name: "2030 to 2031")
    end

    it "creates a new academic year for the next year" do
      expect { current_academic_year.next }.to change(described_class, :count).by(1)

      created_academic_year = current_academic_year.next
      expect(created_academic_year.starts_on).to eq(Date.parse("1 September 2031"))
      expect(created_academic_year.ends_on).to eq(Date.parse("31 August 2032"))
      expect(created_academic_year.name).to eq("2031 to 2032")
    end
  end

  describe "#previous" do
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

    it "returns the previous academic year" do
      expect(current_academic_year.previous).to eq(previous_academic_year)
    end
  end

  context "when the previous academic year does not exist" do
    let!(:current_academic_year) do
      create(:placements_academic_year,
             starts_on: Date.parse("1 September 2030"),
             ends_on: Date.parse("31 August 2031"),
             name: "2030 to 2031")
    end

    it "creates a new academic year for the previous year" do
      expect { current_academic_year.previous }.to change(described_class, :count).by(1)

      created_academic_year = current_academic_year.previous
      expect(created_academic_year.starts_on).to eq(Date.parse("1 September 2029"))
      expect(created_academic_year.ends_on).to eq(Date.parse("31 August 2030"))
      expect(created_academic_year.name).to eq("2029 to 2030")
    end
  end
end

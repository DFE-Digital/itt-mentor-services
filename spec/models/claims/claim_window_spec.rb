# == Schema Information
#
# Table name: claim_windows
#
#  id               :uuid             not null, primary key
#  discarded_at     :date
#  ends_on          :date             not null
#  starts_on        :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#
# Indexes
#
#  index_claim_windows_on_academic_year_id  (academic_year_id)
#  index_claim_windows_on_discarded_at      (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#
require "rails_helper"

RSpec.describe Claims::ClaimWindow, type: :model do
  subject(:claim_window) { build(:claim_window, academic_year:) }

  let(:academic_year) { create(:academic_year, :current) }

  describe "associations" do
    it { is_expected.to belong_to(:academic_year) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:starts_on) }
    it { is_expected.to validate_presence_of(:ends_on) }

    it "validates that end date is always after the start date" do
      claim_window.starts_on = Date.parse("17 July 2024")
      claim_window.ends_on = Date.parse("18 July 2024")

      expect(claim_window).to be_valid

      claim_window.ends_on = Date.parse("16 July 2024")

      expect(claim_window).to be_invalid
      expect(claim_window.errors[:ends_on]).to include("Enter a window closing date that is after the opening date")
    end

    it "validates that the duration of a claim window does not exceed a year" do
      claim_window.starts_on = Date.parse("17 July 2024")
      claim_window.ends_on = Date.parse("18 July 2025")

      expect(claim_window).to be_invalid
      expect(claim_window.errors[:base]).to include("Claim window must be shorter than an academic year")
    end

    context "with validating against existing claim windows" do
      before do
        create(:claim_window, starts_on: Date.parse("1 July 2024"), ends_on: Date.parse("31 July 2024"), academic_year:)
      end

      it "validates that the start date does not fall within an existing claim window" do
        claim_window.starts_on = Date.parse("17 July 2024")
        claim_window.ends_on = Date.parse("27 August 2024")

        expect(claim_window).to be_invalid
        expect(claim_window.errors[:starts_on]).to include("Select a date that is not within an existing claim window")
      end

      it "validates that the end date does not fall within an existing claim window" do
        claim_window.starts_on = Date.parse("1 June 2024")
        claim_window.ends_on = Date.parse("17 July 2024")

        expect(claim_window).to be_invalid
        expect(claim_window.errors[:ends_on]).to include("Select a date that is not within an existing claim window")
      end
    end
  end

  describe "#current?" do
    it "returns true if the current date is inclusively within the starts on and ends on dates", freeze: "17 July 2024" do
      on_start_date = build(:claim_window, starts_on: Date.parse("17 July 2024"), ends_on: Date.parse("27 July 2024"))
      on_end_date = build(:claim_window, starts_on: Date.parse("7 July 2024"), ends_on: Date.parse("17 July 2024"))
      in_between_dates = build(:claim_window, starts_on: Date.parse("7 July 2024"), ends_on: Date.parse("27 July 2024"))

      expect(on_start_date.current?).to be(true)
      expect(on_end_date.current?).to be(true)
      expect(in_between_dates.current?).to be(true)
    end

    it "returns false if the current date is not inclusively within the starts on and ends on dates", freeze: "17 July 2024" do
      before_start_date = build(:claim_window, starts_on: Date.parse("27 July 2024"), ends_on: Date.parse("28 July 2024"))
      after_end_date = build(:claim_window, starts_on: Date.parse("15 July 2024"), ends_on: Date.parse("16 July 2024"))

      expect(before_start_date.current?).to be(false)
      expect(after_end_date.current?).to be(false)
    end
  end

  describe ".find_by_date" do
    it "returns a window that inclusively covers the date provided" do
      previous_window = create(:claim_window, starts_on: Date.parse("7 July 2024"), ends_on: Date.parse("17 July 2024"), academic_year:)
      current_window = create(:claim_window, starts_on: Date.parse("18 July 2024"), ends_on: Date.parse("27 July 2024"), academic_year:)
      next_window = create(:claim_window, starts_on: Date.parse("28 July 2024"), ends_on: Date.parse("7 August 2024"), academic_year:)

      expect(described_class.find_by_date(Date.parse("17 July 2024"))).to eq(previous_window)
      expect(described_class.find_by_date(Date.parse("20 July 2024"))).to eq(current_window)
      expect(described_class.find_by_date(Date.parse("28 July 2024"))).to eq(next_window)
    end
  end

  describe ".current" do
    it "returns the current window", freeze: "17 July 2024" do
      _previous_window = create(:claim_window, starts_on: Date.parse("1 July 2024"), ends_on: Date.parse("11 July 2024"), academic_year:)
      current_window = create(:claim_window, starts_on: Date.parse("12 July 2024"), ends_on: Date.parse("21 July 2024"), academic_year:)
      _next_window = create(:claim_window, starts_on: Date.parse("22 July 2024"), ends_on: Date.parse("31 August 2024"), academic_year:)

      expect(described_class.current).to eq(current_window)
    end
  end

  describe ".previous" do
    it "returns the most recently closed window", freeze: "17 July 2024" do
      _old_window = create(:claim_window, starts_on: Date.parse("7 June 2024"), ends_on: Date.parse("1 July 2024"), academic_year:)
      previous_window = create(:claim_window, starts_on: Date.parse("7 July 2024"), ends_on: Date.parse("17 July 2024"), academic_year:)
      _current_window = create(:claim_window, starts_on: Date.parse("18 July 2024"), ends_on: Date.parse("27 July 2024"), academic_year:)
      _next_window = create(:claim_window, starts_on: Date.parse("28 July 2024"), ends_on: Date.parse("7 August 2024"), academic_year:)

      expect(described_class.previous).to eq(previous_window)
    end
  end
end

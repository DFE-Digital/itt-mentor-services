# == Schema Information
#
# Table name: bank_holidays
#
#  id         :uuid             not null, primary key
#  title      :string
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bank_holidays_on_date  (date) UNIQUE
#

require "rails_helper"

describe BankHoliday, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe ".is_bank_holiday?" do
    let(:bank_holiday_date) { Date.parse("2024-12-25") }
    let(:non_bank_holiday_date) { Date.parse("2024-12-26") }

    before do
      create(:bank_holiday, date: bank_holiday_date, title: "Christmas Day")
    end

    it "returns true for a bank holiday date" do
      expect(described_class.is_bank_holiday?(bank_holiday_date)).to be true
    end

    it "returns false for a non-bank holiday date" do
      expect(described_class.is_bank_holiday?(non_bank_holiday_date)).to be false
    end
  end

  describe ".next_working_day" do
    subject(:next_working_day) { described_class.next_working_day(start_date) }

    context "when the start date is already a working weekday" do
      let(:start_date) { Date.parse("2026-03-18") }

      it "returns the same date" do
        expect(next_working_day).to eq(start_date)
      end
    end

    context "when the start date falls on a weekend" do
      let(:start_date) { Date.parse("2026-03-14") }

      it "returns the following Monday" do
        expect(next_working_day).to eq(Date.parse("2026-03-16"))
      end
    end

    context "when the next weekday is a bank holiday" do
      let(:start_date) { Date.parse("2026-05-23") }

      before do
        create(:bank_holiday, date: Date.parse("2026-05-25"), title: "Spring bank holiday")
      end

      it "skips weekends and bank holidays" do
        expect(next_working_day).to eq(Date.parse("2026-05-26"))
      end
    end

    context "when consecutive weekdays are bank holidays" do
      let(:start_date) { Date.parse("2026-12-25") }

      before do
        create(:bank_holiday, date: Date.parse("2026-12-25"), title: "Christmas Day")
        create(:bank_holiday, date: Date.parse("2026-12-28"), title: "Boxing Day substitute day")
      end

      it "returns the first weekday that is not a bank holiday" do
        expect(next_working_day).to eq(Date.parse("2026-12-29"))
      end
    end
  end
end

require "rails_helper"

RSpec.describe BankHolidays::SyncJob, type: :job do
  describe "#perform" do
    let(:holidays_payload) do
      [
        { "date" => "2026-12-25", "title" => "Christmas Day" },
        { "date" => "2026-12-28", "title" => "Boxing Day (substitute day)" },
      ]
    end

    before do
      allow(GovUk::BankHoliday).to receive(:all).and_return(holidays_payload)
    end

    it "creates bank holidays from the GOV.UK payload" do
      expect {
        described_class.perform_now
      }.to change(BankHoliday, :count).by(2)

      christmas = BankHoliday.find_by(date: Date.parse("2026-12-25"))
      boxing_day_substitute = BankHoliday.find_by(date: Date.parse("2026-12-28"))

      expect(christmas.title).to eq("Christmas Day")
      expect(boxing_day_substitute.title).to eq("Boxing Day (substitute day)")
    end

    it "does not create duplicates for existing dates" do
      create(:bank_holiday, date: Date.parse("2026-12-25"), title: "Existing Christmas title")

      expect {
        described_class.perform_now
      }.to change(BankHoliday, :count).by(1)

      expect(BankHoliday.where(date: Date.parse("2026-12-25")).count).to eq(1)
      expect(BankHoliday.find_by(date: Date.parse("2026-12-25")).title).to eq("Existing Christmas title")
    end
  end
end

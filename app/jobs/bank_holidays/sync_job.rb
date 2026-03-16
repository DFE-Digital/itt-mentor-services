class BankHolidays::SyncJob < ApplicationJob
  include GovUk::BankHoliday
  queue_as :default

  def perform
    bank_holiday_json = GovUk::BankHoliday.all

    bank_holiday_json.each do |holiday|
      bank_holiday_date = Date.parse(holiday["date"].to_s)
      BankHoliday.find_or_create_by!(date: bank_holiday_date) do |bank_holiday|
        bank_holiday.title = holiday["title"]
      end
    end
  end
end

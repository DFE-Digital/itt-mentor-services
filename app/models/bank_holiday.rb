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

class BankHoliday < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :title, presence: true

  def self.is_bank_holiday?(date)
    where(date: date).exists?
  end

  def self.next_working_day(start_date)
    date = start_date
    date += 1.day while !date.on_weekday? || is_bank_holiday?(date)
    date
  end
end

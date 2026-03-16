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

FactoryBot.define do
  factory :bank_holiday do
    date { Date.parse("2024-12-25") }
    title { "Christmas Day" }
  end
end

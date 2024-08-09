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
class AcademicYear < ApplicationRecord
  validates :name, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true, comparison: { greater_than_or_equal_to: :starts_on }

  START_DATE = {
    day: 1,
    month: 9, # September
  }.freeze

  END_DATE = {
    day: 31,
    month: 8, # August
  }.freeze

  def self.for_date(date)
    existing_academic_year = find_by(starts_on: ..date, ends_on: date..)
    return existing_academic_year if existing_academic_year.present?

    start_year = date.month < START_DATE[:month] ? date.year - 1 : date.year
    starts_on = Date.new(start_year, START_DATE[:month], START_DATE[:day])
    ends_on = Date.new(start_year + 1, END_DATE[:month], END_DATE[:day])

    create!(
      starts_on:,
      ends_on:,
      name: "#{start_year} to #{start_year + 1}",
    )
  end
end

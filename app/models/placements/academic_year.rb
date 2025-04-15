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
class Placements::AcademicYear < AcademicYear
  has_many :placements
  has_many :hosting_interests
  has_many :users, foreign_key: :selected_academic_year_id

  def self.current
    for_date(Date.current)
  end

  def current?
    self == self.class.current
  end

  def next
    Placements::AcademicYear.for_date(starts_on + 1.year)
  end

  def previous
    Placements::AcademicYear.for_date(starts_on - 1.year)
  end
end

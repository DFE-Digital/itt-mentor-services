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
  def self.current
    for_date(Date.current)
  end

  def next
    Placements::AcademicYear.for_date(starts_on + 1.year)
  end

  def previous
    Placements::AcademicYear.for_date(starts_on - 1.year)
  end
end

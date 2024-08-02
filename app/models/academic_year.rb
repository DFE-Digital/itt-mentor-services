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
  has_many :claim_windows, class_name: "Claims::ClaimWindow"
  has_many :claims, through: :claim_windows

  validates :name, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true, comparison: { greater_than_or_equal_to: :starts_on }
end

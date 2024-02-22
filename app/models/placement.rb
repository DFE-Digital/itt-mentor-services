# == Schema Information
#
# Table name: placements
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  status     :enum             default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid
#
# Indexes
#
#  index_placements_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Placement < ApplicationRecord
  has_many :placement_mentor_joins
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_subject_joins
  has_many :subjects, through: :placement_subject_joins

  belongs_to :school, class_name: "Placements::School"

  validates :school, :status, :start_date, :end_date, presence: true

  validate :start_date_before_end_date

  def start_date_before_end_date
    return if start_date.blank? || end_date.blank?
    return if start_date.before?(end_date)

    errors.add(:end_date, :before_start_date)
  end
end

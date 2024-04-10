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
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_subject_joins, dependent: :destroy
  has_many :subjects, through: :placement_subject_joins

  belongs_to :school, class_name: "Placements::School"

  accepts_nested_attributes_for :mentors, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  # enum :status, %i[draft submitted approved rejected]

  validates :school, :status, presence: true

  attr_accessor :phase
end

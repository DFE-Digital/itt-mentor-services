# == Schema Information
#
# Table name: subjects
#
#  id           :uuid             not null, primary key
#  code         :string
#  name         :string           not null
#  subject_area :enum
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Subject < ApplicationRecord
  has_many :placement_subject_joins
  has_many :placements, through: :placement_subject_joins

  validates :subject_area, :name, presence: true
end

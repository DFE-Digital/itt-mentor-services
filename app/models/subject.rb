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
  has_many :placement_subject_joins, dependent: :restrict_with_exception
  has_many :placements, through: :placement_subject_joins

  enum :subject_area,
       { primary: "primary", secondary: "secondary" },
       validate: true

  validates :subject_area, :name, presence: true
end

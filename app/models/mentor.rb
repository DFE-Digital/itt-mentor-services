# == Schema Information
#
# Table name: mentors
#
#  id         :uuid             not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  trn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_mentors_on_trn  (trn) UNIQUE
#
class Mentor < ApplicationRecord
  has_many :mentor_memberships
  has_many :schools, through: :mentor_memberships

  has_many :mentor_trainings, class_name: "Claims::MentorTraining"

  has_many :placement_mentor_joins, dependent: :restrict_with_error
  has_many :placements, through: :placement_mentor_joins

  normalizes :trn, with: ->(value) { value.strip }

  validates :first_name, :last_name, presence: true
  validates :trn, presence: true, uniqueness: true, format: /\A\d{7}\z/

  scope :order_by_full_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :trained_in_academic_year, lambda { |academic_year|
    joins(
      mentor_trainings: { claim: :claim_window },
    ).where(
      claim_windows: { academic_year_id: academic_year.id },
    ).distinct
  }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def full_name_possessive
    suffix = if full_name.end_with?("s")
               "'"
             else
               "'s"
             end
    "#{full_name}#{suffix}"
  end
end

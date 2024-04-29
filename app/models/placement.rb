# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  status      :enum             default("draft")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Placement < ApplicationRecord
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_subject_joins, dependent: :destroy
  has_many :subjects, through: :placement_subject_joins

  belongs_to :school, class_name: "Placements::School"
  belongs_to :provider, optional: true, class_name: "::Provider"

  accepts_nested_attributes_for :mentors, allow_destroy: true
  accepts_nested_attributes_for :subjects, allow_destroy: true

  validates :school, :status, presence: true

  delegate :name, to: :provider, prefix: true, allow_nil: true

  scope :order_by_subject_school_name, -> { includes(:subjects, :school).order("subjects.name", "schools.name") }
end

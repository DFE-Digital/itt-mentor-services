# == Schema Information
#
# Table name: mentor_trainings
#
#  id              :uuid             not null, primary key
#  date_completed  :datetime
#  hours_completed :integer
#  training_type   :enum             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  claim_id        :uuid
#  mentor_id       :uuid
#  provider_id     :uuid
#
# Indexes
#
#  index_mentor_trainings_on_claim_id     (claim_id)
#  index_mentor_trainings_on_mentor_id    (mentor_id)
#  index_mentor_trainings_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (provider_id => providers.id)
#
class Claims::MentorTraining < ApplicationRecord
  belongs_to :claim
  belongs_to :mentor, optional: true
  belongs_to :provider, optional: true

  audited associated_with: :claim

  enum :training_type, {
    initial: "initial",
    refresher: "refresher",
  }, default: :initial, validate: { allow_nil: false }

  validates(
    :hours_completed,
    numericality: { greater_than: 0, less_than_or_equal_to: 20, only_integer: true },
    allow_nil: true,
  )

  scope :without_hours, -> { where(hours_completed: nil).order_by_mentor_full_name }
  scope :order_by_mentor_full_name, -> { joins(:mentor).merge(Mentor.order_by_full_name) }

  delegate :full_name, to: :mentor, prefix: true, allow_nil: true
  delegate :name, to: :provider, prefix: true, allow_nil: true
end

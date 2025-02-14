# == Schema Information
#
# Table name: mentor_trainings
#
#  id                 :uuid             not null, primary key
#  date_completed     :datetime
#  hours_clawed_back  :integer
#  hours_completed    :integer
#  not_assured        :boolean          default(FALSE)
#  reason_clawed_back :text
#  reason_not_assured :text
#  reason_rejected    :text
#  rejected           :boolean          default(FALSE)
#  training_type      :enum             default("initial"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  claim_id           :uuid
#  mentor_id          :uuid
#  provider_id        :uuid
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
  belongs_to :mentor
  belongs_to :provider

  audited associated_with: :claim

  enum :training_type, {
    initial: "initial",
    refresher: "refresher",
  }, default: :initial, validate: true

  validates :hours_completed,
            allow_nil: true,
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: :max_hours,
              only_integer: true,
            }
  validates :reason_rejected, presence: true, if: -> { rejected }
  validates :reason_not_assured, presence: true, if: -> { not_assured }

  scope :without_hours, -> { where(hours_completed: nil).order_by_mentor_full_name }
  scope :order_by_mentor_full_name, -> { joins(:mentor).merge(Mentor.order_by_full_name) }
  scope :not_assured, -> { where(not_assured: true) }

  delegate :full_name, to: :mentor, prefix: true, allow_nil: true
  delegate :name, to: :provider, prefix: true, allow_nil: true

  def set_training_type
    self.training_type = training_allowance.training_type
  end

  private

  def max_hours
    training_allowance.remaining_hours
  end

  def training_allowance
    @training_allowance ||= Claims::TrainingAllowance.new(
      mentor:,
      provider:,
      academic_year: claim.claim_window.academic_year,
      claim_to_exclude: claim,
    )
  end
end

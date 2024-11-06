# == Schema Information
#
# Table name: mentor_trainings
#
#  id              :uuid             not null, primary key
#  date_completed  :datetime
#  hours_completed :integer
#  training_type   :enum             default("initial"), not null
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
  belongs_to :mentor
  belongs_to :provider

  audited associated_with: :claim

  enum :training_type, {
    initial: "initial",
    refresher: "refresher",
  }, default: :initial, validate: true

  before_validation :set_training_type

  validates :hours_completed,
            allow_nil: true,
            # TODO: Remove this 'unless' condition once claim revisions have been removed.
            # The 'internal draft' state that powers revisions is confusing, but in this case we need to
            # skip this validation rule so that Claims::Claim::CreateRevision can successfully duplicate
            # the claim and its mentor training records without breaching the remaining training allowance.
            # The validity of mentor training records is still checked before claims can be submitted, so this
            # doesn't open up a loophole. It's just a quirk due to the way claim revisions are modelled.
            # https://trello.com/c/4riw52nH/230-replace-claim-revisions-with-the-wizard-pattern
            unless: -> { claim&.internal_draft? },
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: :max_hours,
              only_integer: true,
            }

  scope :without_hours, -> { where(hours_completed: nil).order_by_mentor_full_name }
  scope :order_by_mentor_full_name, -> { joins(:mentor).merge(Mentor.order_by_full_name) }

  delegate :full_name, to: :mentor, prefix: true, allow_nil: true
  delegate :name, to: :provider, prefix: true, allow_nil: true

  private

  def set_training_type
    return if training_allowance.nil?

    self.training_type = training_allowance.training_type
  end

  def max_hours
    training_allowance.remaining_hours
  end

  def training_allowance
    return if [mentor, provider, claim].any?(&:nil?)

    @training_allowance ||= Claims::TrainingAllowance.new(
      mentor:,
      provider:,
      academic_year: claim.claim_window.academic_year,
      claim_to_exclude: claim,
    )
  end
end

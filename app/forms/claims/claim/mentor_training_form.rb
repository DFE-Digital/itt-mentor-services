class Claims::Claim::MentorTrainingForm < ApplicationForm
  MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER = 20

  attr_accessor :claim, :mentor_training, :hours_completed, :custom_hours_completed

  validates(
    :hours_completed,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: :max_hours,
    },
    unless: :custom_hours_selected?,
  )

  validates(
    :custom_hours_completed,
    presence: true,
    numericality: { only_integer: true },
    between: { min: 1, max: :max_hours },
    if: :custom_hours_selected?,
  )

  delegate :school, to: :claim
  delegate :mentor, :provider, :mentor_full_name, :provider_name, to: :mentor_training

  def initialize(attributes = {})
    super

    self.hours_completed ||= mentor_training.hours_completed

    if hours_completed.present? && hours_completed.to_i < max_hours
      self.custom_hours_completed ||= hours_completed
      self.hours_completed = "custom"
    end
  end

  def persist
    mentor_training.hours_completed = custom_hours_selected? ? custom_hours_completed : hours_completed
    mentor_training.save!
  end

  def back_path
    if mentor_trainings.index(mentor_training).zero?
      edit_claims_school_claim_mentors_path(school, claim)
    else
      edit_claims_school_claim_mentor_training_path(school, claim, previous_mentor_training)
    end
  end

  def success_path
    if claim.mentor_trainings.without_hours.any?
      edit_claims_school_claim_mentor_training_path(school, claim, claim.mentor_trainings.without_hours.first)
    else
      check_claims_school_claim_path(school, claim)
    end
  end

  def custom_hours_selected?
    @custom_hours_selected ||= hours_completed == "custom"
  end

  def max_hours
    @max_hours ||= Claims::Mentor::CalculateRemainingMentorTrainingHoursForProvider.call(mentor:, provider:, mentor_training:)
  end

  def max_hours_equals_maximum_claimable_hours?
    max_hours == MAXIMUM_CLAIMABLE_HOURS_PER_PROVIDER
  end

  private

  def mentor_trainings
    @mentor_trainings ||= claim.mentor_trainings.order_by_mentor_full_name
  end

  def previous_mentor_training
    mentor_trainings[mentor_trainings.index(mentor_training) - 1]
  end
end

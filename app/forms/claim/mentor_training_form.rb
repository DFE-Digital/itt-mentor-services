class Claim::MentorTrainingForm < ApplicationForm
  DEFAULT_HOURS_COMPLETED = %w[6 20].freeze
  attr_accessor :claim, :mentor_training, :hours_completed, :custom_hours_completed

  validates :hours_completed, presence: true, unless: :custom_hours?
  validates :custom_hours_completed, presence: true, if: :custom_hours?

  validate :validate_mentor_training_hours

  delegate :mentor_full_name, to: :mentor_training

  def persist
    updated_mentor_training.save!
  end

  def back_path
    if mentor_trainings.index(mentor_training).zero?
      edit_claims_school_claim_mentor_path(claim.school, claim, mentor_training.mentor_id)
    else
      previous_mentor_training = mentor_trainings[mentor_trainings.index(mentor_training) - 1]
      edit_claims_school_claim_mentor_training_path(
        claim.school,
        claim,
        previous_mentor_training,
        params: {
          claim_mentor_training_form: { hours_completed: previous_mentor_training.hours_completed },
        },
      )
    end
  end

  def success_path
    if claim.mentor_trainings.without_hours.any?
      edit_claims_school_claim_mentor_training_path(
        claim.school,
        claim,
        claim.mentor_trainings.without_hours.first,
      )
    else
      check_claims_school_claim_path(claim.school, claim)
    end
  end

  def custom_hours?
    @custom_hours ||= hours_completed == "on" || custom_hours_completed?
  end

  private

  def custom_hours_completed?
    if hours_completed.present?
      !DEFAULT_HOURS_COMPLETED.include?(hours_completed)
    end
  end

  def mentor_trainings
    @mentor_trainings ||= claim.mentor_trainings.order_by_mentor_full_name
  end

  def updated_mentor_training
    @updated_mentor_training ||= begin
      mentor_training.hours_completed = custom_hours? ? custom_hours_completed : hours_completed
      mentor_training
    end
  end

  def validate_mentor_training_hours
    if updated_mentor_training.invalid? && updated_mentor_training.errors[:hours_completed]
      errors.add(:custom_hours_completed, updated_mentor_training.errors.first.message)
    end
  end
end

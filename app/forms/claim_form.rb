class ClaimForm < ApplicationForm
  STEPS = %w[providers mentors].freeze

  attr_accessor :claim, :step, :claim_params

  validates :claim, :step, :claim_params, presence: true
  validates :step, inclusion: { in: STEPS }
  validate :validate_provider, if: proc { |form| form.step == "providers" }
  validate :validate_mentor, if: proc { |form| form.step == "mentors" }

  def persist
    updated_claim.save!
  end

  private

  def updated_claim
    @updated_claim ||= begin
      claim.assign_attributes(claim_params)
      claim
    end
  end

  def validate_provider
    if updated_claim.provider_id.nil?
      updated_claim.errors.add(:provider_id)
      add_errors_to_form
    end
  end

  def validate_mentor
    updated_claim.mentor_trainings.each do |mentor_training|
      next unless mentor_training.mentor_id.nil?

      mentor_training.errors.add(:mentor_id, :blank)
      updated_claim.errors.add(:base, :enter_mentor_name)
      add_errors_to_form
    end
  end

  def add_errors_to_form
    updated_claim.errors.each do |err|
      errors.add(err.attribute, err.message)
    end
  end
end

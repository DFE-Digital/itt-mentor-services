class ClaimForm
  include ActiveModel::Model
  STEPS = %w[providers mentors].freeze

  attr_accessor :claim, :step, :claim_params

  def save
    claim.assign_attributes(claim_params)
    return false unless valid?

    claim.save!
  end

  def valid?
    claim.valid? && valid_providers? && valid_mentors?
  end

  private

  def valid_providers?
    return true unless step == "providers"

    claim.mentor_trainings.each do |mentor_training|
      if mentor_training.provider_id.nil?
        mentor_training.errors.add(:provider_id, :blank)
        claim.errors.add(:base, :enter_provider_name)
      end
    end

    claim.errors.blank?
  end

  def valid_mentors?
    return true unless step == "mentors"

    claim.mentor_trainings.each do |mentor_training|
      if mentor_training.mentor_id.nil?
        mentor_training.errors.add(:mentor_id, :blank)
        claim.errors.add(:base, :enter_mentor_name)
      end
    end

    claim.errors.blank?
  end
end

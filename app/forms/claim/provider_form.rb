class Claim::ProviderForm < ApplicationForm
  attr_accessor :id, :provider_id, :school, :current_user

  validate :validate_provider

  def persist
    updated_claim.save!
  end

  def to_model
    claim
  end

  def claim
    @claim ||= school.claims.find_or_initialize_by(id:)
  end

  def back_path
    if claim.ready_to_be_checked?
      check_claims_school_claim_path(claim.school, claim)
    else
      claims_school_claims_path(claim.school)
    end
  end

  def update_success_path
    if updated_claim.ready_to_be_checked?
      check_claims_school_claim_path(school, claim)
    else
      edit_claims_school_claim_mentor_path(school, claim, claim)
    end
  end

  private

  def updated_claim
    @updated_claim ||= begin
      claim.provider_id = provider_id
      claim.status = :internal
      claim.created_by = current_user
      claim
    end
  end

  def validate_provider
    if updated_claim.provider_id.nil?
      updated_claim.errors.add(:provider_id, :blank)
      add_errors_to_form
    end
  end

  def add_errors_to_form
    updated_claim.errors.each do |err|
      errors.add(err.attribute, err.message)
    end
  end
end

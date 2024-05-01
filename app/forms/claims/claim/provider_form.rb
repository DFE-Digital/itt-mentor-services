class Claims::Claim::ProviderForm < ApplicationForm
  attr_accessor :id, :provider_id, :school, :current_user

  validates :provider_id, presence: true

  def initialize(attributes = {})
    super

    self.provider_id ||= claim.provider_id
  end

  def persist
    return true if claim.provider_id == provider_id

    ActiveRecord::Base.transaction do
      claim.provider_id = provider_id
      claim.mentor_trainings.update_all(provider_id:)
      claim.status = :internal_draft if claim.status.nil?
      claim.created_by ||= current_user
      claim.save!
    end
  end

  def edit_back_path
    if claim.reviewed?
      check_claims_school_claim_path(claim.school, claim)
    else
      claims_school_claims_path(claim.school)
    end
  end

  def update_success_path
    if claim.reviewed?
      check_claims_school_claim_path(claim.school, claim)
    else
      edit_claims_school_claim_mentors_path(claim.school, claim)
    end
  end

  def claim
    @claim ||= school.claims.find_or_initialize_by(id:)
  end
end

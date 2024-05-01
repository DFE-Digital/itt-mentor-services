class Claims::Support::Claim::ProviderForm < Claims::Claim::ProviderForm
  def edit_back_path
    if claim.reviewed?
      check_claims_support_school_claim_path(claim.school, claim)
    else
      claims_support_school_claims_path(claim.school)
    end
  end

  def update_success_path
    if claim.reviewed?
      check_claims_support_school_claim_path(claim.school, claim)
    else
      edit_claims_support_school_claim_mentors_path(claim.school, claim)
    end
  end
end

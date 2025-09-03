class Claims::SubmitClaimsToBePaidWizard::CheckYourAnswersStep < BaseStep
  def submitted_claims
    @submitted_claims ||= Claims::Claim.submitted.where(claim_window: wizard.steps[:select_claim_window].claim_window)
  end
end

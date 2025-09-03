class Claims::SubmitClaimsToBePaidWizard::SelectClaimWindowStep < BaseStep
  attribute :claim_window

  validates :claim_window, presence: true

  def claim_windows
    @claim_windows ||= Claims::ClaimWindow.where(id: submitted_claims
                                          .select(:claim_window_id).distinct)
                                          .order(starts_on: :desc)
                                          .decorate
  end

  def submitted_claims
    @submitted_claims ||= Claims::Claim.submitted
  end
end

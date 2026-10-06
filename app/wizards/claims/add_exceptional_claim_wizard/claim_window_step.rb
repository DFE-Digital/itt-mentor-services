class Claims::AddExceptionalClaimWizard::ClaimWindowStep < BaseStep
  attribute :id

  validates :id, inclusion: { in: ->(step) { step.claim_windows.ids.map(&:to_s) } }

  def claim_windows
    @claim_windows ||= Claims::ClaimWindow
      .where(ends_on: ...Date.current)
      .includes(:academic_year)
      .order(ends_on: :desc)
  end

  def claim_window
    @claim_window ||= claim_windows.find_by(id:)
  end
end

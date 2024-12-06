describe Claims::Claim::Sampling::CSV::PaidClaimFinder do
  let(:current_academic_year) do
    AcademicYear.for_date(Date.current) || create(:academic_year, :current)
  end
  let(:current_claim_window) do
    create(:claim_window,
           starts_on: current_academic_year.starts_on + 1.day,
           ends_on: current_academic_year.starts_on + 1.month,
           academic_year: current_academic_year)
  end
  let(:current_year_paid_claim) do
    create(:claim, :submitted, status: :paid, claim_window: current_claim_window)
  end
  let(:another_paid_claim) { create(:claim, :submitted, status: :paid) }
  let(:current_year_draft_claim) { create(:claim, :draft, claim_window: current_claim_window) }

  describe "#call" do
  end
end

require "rails_helper"

RSpec.describe Claims::Sampling::FlagCollectionForSamplingJob, type: :job do
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
  let(:claim_ids) { [current_year_paid_claim.id, another_paid_claim.id, current_year_draft_claim.id] }

  describe "#perform" do
    it "enqueues a Claims::Sampling::FlagForSamplingJob per claim ID" do
      expect { described_class.perform_now(claim_ids) }.to have_enqueued_job(
        Claims::Sampling::FlagForSamplingJob,
      ).exactly(:once)
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(claim_ids)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end

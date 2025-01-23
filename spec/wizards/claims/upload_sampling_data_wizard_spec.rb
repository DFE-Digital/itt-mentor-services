require "rails_helper"

RSpec.describe Claims::UploadSamplingDataWizard do
  subject(:wizard) { described_class.new(current_user:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let!(:current_academic_year) do
    AcademicYear.for_date(Date.current) || create(:academic_year, :current)
  end
  let(:current_claim_window) do
    create(:claim_window,
           starts_on: current_academic_year.starts_on + 1.day,
           ends_on: current_academic_year.starts_on + 1.month,
           academic_year: current_academic_year)
  end
  let(:current_year_paid_claim) do
    create(:claim, :submitted,
           status: :paid,
           claim_window: current_claim_window,
           reference: "11111111")
  end

  let(:current_user) { create(:claims_user) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no paid claims exist for the current academic year" do
      it { is_expected.to contain_exactly(:no_claims) }
    end

    context "when paid claims exist for the current academic year" do
      before { current_year_paid_claim }

      it { is_expected.to eq(%i[upload confirmation]) }
    end
  end

  describe "#upload_data" do
    let(:claim_ids) { [current_year_paid_claim.id] }
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "claim_ids" => claim_ids,
          "csv_content" => csv_content,
        },
      }
    end

    context "when the steps are valid" do
      let(:csv_content) { "claim_reference,sample_reason\r\n11111111,ABCD" }

      it "queues a job to flag the claim for sampling" do
        expect { wizard.upload_data }.to have_enqueued_job(
          Claims::Sampling::CreateAndDeliverJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      let(:csv_content) { "claim_reference,sample_reason\r\n11111111,ABCD\r\n22222222,Some reason" }

      it "returns an invalid wizard error" do
        expect { wizard.upload_data }.to raise_error("Invalid wizard state")
      end
    end
  end

  describe "#paid_claims" do
    subject(:paid_claims) { wizard.paid_claims }

    let(:current_academic_year) do
      AcademicYear.for_date(Date.current) || create(:academic_year, :current)
    end
    let(:current_claim_window) do
      create(:claim_window,
             starts_on: current_academic_year.starts_on + 1.day,
             ends_on: current_academic_year.starts_on + 1.month,
             academic_year: current_academic_year)
    end
    let(:another_paid_claim) { create(:claim, :submitted, status: :paid) }
    let(:current_year_draft_claim) { create(:claim, :draft, claim_window: current_claim_window) }

    before do
      current_year_paid_claim
      another_paid_claim
      current_year_draft_claim
    end

    it "returns only paid claim, submitted during the current academic year" do
      expect(paid_claims).to contain_exactly(current_year_paid_claim, another_paid_claim)
    end
  end

  describe "#uploaded_claim_ids" do
    subject(:paid_claims) { wizard.uploaded_claim_ids }

    context "when the upload step is blank" do
      it "returns an empty array" do
        expect(paid_claims).to eq([])
      end
    end

    context "when the upload step is not present" do
      let(:claim_ids) { [current_year_paid_claim.id] }
      let(:state) do
        {
          "upload" => {
            "claim_ids" => claim_ids,
          },
        }
      end

      it "returns the claim ids from the upload step" do
        expect(paid_claims).to eq([current_year_paid_claim.id])
      end
    end
  end
end

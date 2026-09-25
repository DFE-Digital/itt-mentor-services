require "rails_helper"

RSpec.describe Claims::UploadPayerPaymentResponseWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil, current_user:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_user) { create(:claims_support_user) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no paid claims exist for the current academic year" do
      it { is_expected.to contain_exactly(:no_claims) }
    end

    context "when paid claims exist for the current academic year" do
      before { create(:claim, :payment_in_progress) }

      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when the csv contains invalid inputs" do
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason\r\n" \
        "22222222,paid,Some reason"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content,
          },
        }
      end

      before do
        create(:claim, :payment_in_progress, reference: 11_111_111)
      end

      it { is_expected.to eq(%i[upload upload_errors]) }
    end
  end

  describe "#upload_payer_responses" do
    subject(:upload_payer_responses) { wizard.upload_payer_responses }

    let(:payment_in_progress_claim) do
      create(:claim, :payment_in_progress, reference: 11_111_111)
    end
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end

    before { payment_in_progress_claim }

    context "when the steps are valid" do
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason\r\n" \
        "11111111,paid,Some reason"
      end

      it "queues a job to flag the claim for sampling" do
        expect { upload_payer_responses }.to have_enqueued_job(
          Claims::Payment::UpdateCollectionWithPayerResponseJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      context "when the a step is invalid" do
        let(:csv_content) { nil }

        it "returns an invalid wizard error" do
          expect { upload_payer_responses }.to raise_error("Invalid wizard state")
        end
      end

      context "when the uploaded content includes an invalid input" do
        let(:csv_content) do
          "claim_reference,claim_status,claim_unpaid_reason\r\n" \
          "11111111,paid,Some reason\r\n" \
          "22222222,unpaid,"
        end

        it "returns an invalid wizard error" do
          expect { upload_payer_responses }.to raise_error("Invalid wizard state")
        end
      end
    end
  end

  describe "#payment_in_progress_claims" do
    subject(:payment_in_progress_claims) { wizard.payment_in_progress_claims }

    let(:submitted_claim) { create(:claim, :submitted) }
    let!(:payment_in_progress_claim) { create(:claim, :payment_in_progress) }
    let(:draft_claim) { create(:claim) }

    before do
      submitted_claim
      draft_claim
    end

    it "returns all claims with the status 'payment_in_progress" do
      expect(payment_in_progress_claims).to contain_exactly(payment_in_progress_claim)
    end
  end

  describe "#claim_update_details" do
    subject(:claim_update_details) { wizard.claim_update_details }

    context "when the upload step is blank" do
      it "returns an empty array" do
        expect(claim_update_details).to eq([])
      end
    end

    context "when the upload step is present" do
      let!(:payment_in_progress_claim_1) do
        create(:claim, :payment_in_progress, reference: 11_111_111)
      end
      let!(:payment_in_progress_claim_2) do
        create(:claim, :payment_in_progress, reference: 22_222_222)
      end
      let(:csv_content) do
        "claim_reference,claim_status,claim_unpaid_reason\r\n" \
        "11111111,paid,\r\n" \
        "22222222,unpaid,Some reason"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content,
          },
        }
      end

      it "returns the claim_update_details from the upload step" do
        expect(claim_update_details).to contain_exactly(
          {
            id: payment_in_progress_claim_1.id,
            status: "paid",
            unpaid_reason: nil,
          },
          {
            id: payment_in_progress_claim_2.id,
            status: "unpaid",
            unpaid_reason: "Some reason",
          },
        )
      end
    end
  end
end

require "rails_helper"

RSpec.describe Claims::UploadESFAClawbackResponseWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no clawback in progress claims exist" do
      it { is_expected.to contain_exactly(:no_claims) }
    end

    context "when clawback in progress claims exist" do
      before { create(:claim, :submitted, status: :clawback_in_progress) }

      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when the csv contains invalid inputs" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "22222222,John Smith,Some reason,2"
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
        create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
      end

      it { is_expected.to eq(%i[upload upload_errors]) }
    end
  end

  describe "#upload_esfa_responses" do\
    let(:clawback_in_progress_claim) do
      create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
    end
    let(:mentor) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end

    before do
      create(
        :mentor_training,
        :rejected,
        mentor:,
        claim: clawback_in_progress_claim,
        hours_completed: 20,
      )
    end

    context "when the steps are valid" do
      let(:csv_content) do
        "claim_reference,claim_status\r\n" \
        "11111111,clawback_complete"
      end

      it "queues a job to update the claim with the ESFA response" do
        expect { wizard.upload_esfa_responses }.to have_enqueued_job(
          Claims::Clawback::UpdateCollectionWithESFAResponseJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      context "when the a step is valid" do
        let(:csv_content) { nil }

        it "returns an invalid wizard error" do
          expect { wizard.upload_esfa_responses }.to raise_error("Invalid wizard state")
        end
      end

      context "when the uploaded content includes an invalid input" do
        let(:csv_content) do
          "claim_reference,claim_status\r\n" \
          "11111111,clawback_complete\r\n" \
          "22222222,paid"
        end

        it "returns an invalid wizard error" do
          expect { wizard.upload_esfa_responses }.to raise_error("Invalid wizard state")
        end
      end
    end
  end

  describe "#clawback_in_progress_claims" do
    subject(:clawback_in_progress_claims) { wizard.clawback_in_progress_claims }

    let(:submitted_claim) { create(:claim, :submitted) }
    let!(:clawback_in_progress_claim) { create(:claim, :submitted, status: :clawback_in_progress) }
    let(:sampling_in_progress_claim) { create(:claim, :submitted, status: :sampling_in_progress) }
    let(:draft_claim) { create(:claim) }

    before do
      submitted_claim
      sampling_in_progress_claim
      draft_claim
    end

    it "returns all claims with the status 'sampling_in_progress" do
      expect(clawback_in_progress_claims).to contain_exactly(clawback_in_progress_claim)
    end
  end

  describe "#claims_count" do
    subject(:claims_count) { wizard.claims_count }

    let(:clawback_in_progress_claim_1) do
      create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
    end
    let(:clawback_in_progress_claim_2) do
      create(:claim, :submitted, status: :clawback_in_progress, reference: 22_222_222)
    end
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end
    let(:csv_content) do
      "claim_reference,claim_status\r\n" \
      "11111111,clawback_complete\r\n" \
      "22222222,clawback_in_progress\r\n" \
      ","
    end

    before do
      clawback_in_progress_claim_1
      clawback_in_progress_claim_2
    end

    it "returns the number of rows within the CSV" do
      expect(claims_count).to eq(2)
    end
  end
end

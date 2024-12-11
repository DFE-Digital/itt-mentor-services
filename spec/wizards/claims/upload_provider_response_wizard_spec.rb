require "rails_helper"

RSpec.describe Claims::UploadProviderResponseWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when no paid claims exist for the current academic year" do
      it { is_expected.to contain_exactly(:no_claims) }
    end

    context "when paid claims exist for the current academic year" do
      before { create(:claim, :submitted, status: :sampling_in_progress) }

      it { is_expected.to eq(%i[upload confirmation]) }
    end
  end

  describe "#upload_provider_responses" do\
    let(:sampling_in_progress_claim) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
    end
    let(:mentor) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
    let(:mentor_trainings) { create(:mentor_training, mentor:, claim: sampling_in_progress_claim) }
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "claim_update_details" => [
            {
              id: sampling_in_progress_claim.id,
              status: :sampling_provider_not_approved,
              not_assured_reason: nil,
            },
          ],
          "csv_content" => csv_content,
        },
      }
    end

    before { mentor_trainings }

    context "when the steps are valid" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
        "11111111,John Smith,true,Some reason"
      end

      it "queues a job to flag the claim for sampling" do
        expect { wizard.upload_provider_responses }.to have_enqueued_job(
          Claims::Sampling::UpdateCollectionWithProviderResponseJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
        "11111111,John Smith,true,Some reason\r\n" \
        "22222222,Maggie Smith,true,Another reason"
      end

      it "returns an invalid wizard error" do
        expect { wizard.upload_provider_responses }.to raise_error("Invalid wizard state")
      end
    end
  end

  describe "#sampled_claims" do
    subject(:sampled_claims) { wizard.sampled_claims }

    let(:submitted_claim) { create(:claim, :submitted) }
    let!(:sampling_in_progress_claim) { create(:claim, :submitted, status: :sampling_in_progress) }
    let(:draft_claim) { create(:claim) }

    it "returns all claims with the status 'sampling_in_progress" do
      expect(sampled_claims).to contain_exactly(sampling_in_progress_claim)
    end
  end

  describe "#claim_update_details" do
    subject(:claim_update_details) { wizard.claim_update_details }

    context "when the upload step is blank" do
      it "returns an empty array" do
        expect(claim_update_details).to eq([])
      end
    end

    context "when the upload step is not present" do
      let!(:sampling_in_progress_claims) do
        create_list(:claim, 2, :submitted, status: :sampling_in_progress)
      end
      let(:claim_ids) { [current_year_paid_claim.id] }
      let(:state) do
        {
          "upload" => {
            "claim_update_details" => [
              {
                id: sampling_in_progress_claims[0].id,
                status: :sampling_provider_not_approved,
                not_assured_reason: nil,
              },
              {
                id: sampling_in_progress_claims[1].id,
                status: :sampling_provider_not_approved,
                not_assured_reason: nil,
              },
            ],
          },
        }
      end

      it "returns the claim_update_details from the upload step" do
        expect(claim_update_details).to contain_exactly({
          id: sampling_in_progress_claims[0].id,
          status: :sampling_provider_not_approved,
          not_assured_reason: nil,
        }, {
          id: sampling_in_progress_claims[1].id,
          status: :sampling_provider_not_approved,
          not_assured_reason: nil,
        })
      end
    end
  end
end

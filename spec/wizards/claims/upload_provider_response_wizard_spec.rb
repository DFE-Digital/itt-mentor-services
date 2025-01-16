require "rails_helper"

RSpec.describe Claims::UploadProviderResponseWizard do
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
      before { create(:claim, :submitted, status: :sampling_in_progress) }

      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when the csv contains invalid inputs" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
        "22222222,John Smith,true,Some reason"
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
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end

      it { is_expected.to eq(%i[upload upload_errors]) }
    end
  end

  describe "#upload_provider_responses" do\
    let(:sampling_in_progress_claim) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
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
      create(:mentor_training, mentor:, claim: sampling_in_progress_claim)
    end

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
      context "when the a step is valid" do
        let(:csv_content) { nil }

        it "returns an invalid wizard error" do
          expect { wizard.upload_provider_responses }.to raise_error("Invalid wizard state")
        end
      end

      context "when the uploaded content includes an invalid input" do
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
  end

  describe "#sampled_claims" do
    subject(:sampled_claims) { wizard.sampled_claims }

    let(:submitted_claim) { create(:claim, :submitted) }
    let!(:sampling_in_progress_claim) { create(:claim, :submitted, status: :sampling_in_progress) }
    let(:draft_claim) { create(:claim) }

    before do
      submitted_claim
      draft_claim
    end

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

    context "when the upload step is present" do
      let(:sampling_in_progress_claim_1) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
      let(:sampling_in_progress_claim_2) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 22_222_222)
      end
      let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
        "11111111,John Smith,false,Some reason\r\n" \
        "22222222,Jane Doe,true,"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content,
          },
        }
      end
      let(:john_smith_mentor_training) do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
      end
      let(:jane_doe_mentor_training) do
        create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_2)
      end

      before do
        john_smith_mentor_training
        jane_doe_mentor_training
      end

      it "returns the claim_update_details from the upload step" do
        expect(claim_update_details).to contain_exactly(
          {
            id: sampling_in_progress_claim_1.id,
            status: :sampling_provider_not_approved,
            provider_responses: [
              { id: john_smith_mentor_training.id, not_assured: true, reason_not_assured: "Some reason" },
            ],
          },
          {
            id: sampling_in_progress_claim_2.id,
            status: :paid,
            provider_responses: [
              { id: jane_doe_mentor_training.id, not_assured: false, reason_not_assured: nil },
            ],
          },
        )
      end
    end
  end

  describe "#grouped_csv_rows" do
    let(:sampling_in_progress_claim_1) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
    end
    let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
    let(:sampling_in_progress_claim_2) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 22_222_222)
    end
    let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
    let(:csv_content) do
      "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
      "11111111,John Smith,false,Some reason\r\n" \
      "22222222,Jane Doe,true,"
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
      create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
      create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_2)
    end

    it "returns the groups rows from the CSV uploaded to the upload step" do
      expect(wizard.grouped_csv_rows["11111111"][0].to_h).to eq(
        {
          "claim_reference" => "11111111",
          "mentor_full_name" => "John Smith",
          "claim_assured" => "false",
          "claim_not_assured_reason" => "Some reason",
        },
      )
      expect(wizard.grouped_csv_rows["22222222"][0].to_h).to eq(
        {
          "claim_reference" => "22222222",
          "mentor_full_name" => "Jane Doe",
          "claim_assured" => "true",
          "claim_not_assured_reason" => nil,
        },
      )
    end
  end
end

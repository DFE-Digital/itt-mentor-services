require "rails_helper"

RSpec.describe Claims::UploadUsersWizard do
  subject(:wizard) { described_class.new(school:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:claims_school) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no errors in the upload step" do
      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when there are errors in the upload step" do
      let(:csv_content) do
        "first_name,last_name,email\r\n" \
        "John,Smith,invalid_email"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content,
          },
        }
      end

      it { is_expected.to eq(%i[upload upload_errors]) }
    end
  end

  describe "#upload_users" do
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end

    context "when the steps are valid" do
      let(:csv_content) do
        "first_name,last_name,email\r\n" \
        "John,Smith,john_smith@example.com"
      end

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
end

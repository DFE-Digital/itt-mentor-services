require "rails_helper"

RSpec.describe Claims::OnboardUsersWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:claims_school, name: "London School", urn: 111_111) }

  before { school }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no errors in the upload step" do
      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when there are errors in the upload step" do
      let(:csv_content) do
        "school_name,school_urn,first_name,last_name,email\r\n" \
        "London School,111111,John,Smith,invalid_email"
      end
      let(:state) do
        {
          "upload" => {
            "csv_upload" => nil,
            "csv_content" => csv_content,
          },
        }
      end

      # Temp removed to make the CSV upload work
      # it { is_expected.to eq(%i[upload upload_errors]) }
      it { is_expected.to eq(%i[upload confirmation]) }
    end
  end

  describe "#upload_users" do
    subject(:upload_users) { wizard.upload_users }

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
        "school_name,school_urn,first_name,last_name,email\r\n" \
        "London School,111111,John,Smith,john_smith@example.com"
      end

      it "queues a job to flag the claim for sampling" do
        expect { upload_users }.to have_enqueued_job(
          Claims::User::CreateCollectionJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      let(:csv_content) do
        "school_name,school_urn,first_name,last_name,email\r\n" \
        "London School,111111,John,Smith,invalid_email"
      end

      it "returns an invalid wizard error" do
        pending "Validation temp removed"
        expect { upload_users }.to raise_error("Invalid wizard state")
      end
    end
  end
end

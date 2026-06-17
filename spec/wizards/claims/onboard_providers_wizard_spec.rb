require "rails_helper"

RSpec.describe Claims::OnboardProvidersWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:provider) { create(:claims_provider, name: "London Provider", code: "ABC") }

  before { provider }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no errors in the upload step" do
      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when there are errors in the upload step" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,John,Smith,invalid_email"
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

  describe "#upload_providers" do
    subject(:upload_providers) { wizard.upload_providers }

    let(:csv_content) do
      "provider_code,first_name,last_name,email\r\n" \
      "ABC,John,Smith,john_smith@example.com"
    end

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
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,John,Smith,john_smith@example.com"
      end

      it "queues a job to create provider users" do
        expect { upload_providers }.to have_enqueued_job(
          Claims::ProviderUser::CreateCollectionJob,
        ).exactly(:once)
      end
    end

    context "when an email is invalid" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ABC,John,Smith,invalid_email"
      end

      it "raises an invalid wizard state error" do
        expect { upload_providers }.to raise_error("Invalid wizard state")
      end
    end

    context "when a provider code is invalid" do
      let(:csv_content) do
        "provider_code,first_name,last_name,email\r\n" \
        "ZZZ,John,Smith,john_smith@example.com"
      end

      it "raises an invalid wizard state error" do
        expect { upload_providers }.to raise_error("Invalid wizard state")
      end
    end

    context "when provider user details are blank" do
      let(:csv_content) { "provider_code,first_name,last_name,email\r\n,,," }

      it "does not enqueue a provider user collection job" do
        expect { upload_providers }.not_to have_enqueued_job(
          Claims::ProviderUser::CreateCollectionJob,
        )
      end
    end
  end

  describe "#provider_user_details" do
    subject(:provider_user_details) { wizard.send(:provider_user_details) }

    let(:other_provider) { create(:claims_provider, name: "Guildford Provider", code: "XYZ") }
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end
    let(:csv_content) do
      "provider_code,first_name,last_name,email\r\n" \
      "ZZZ,No,Provider,missing@example.com\r\n" \
      "ABC,Bad,Email,invalid_email\r\n" \
      "XYZ,Sue,Doe,sue_doe@example.com"
    end

    before do
      provider
      other_provider
    end

    it "returns only valid rows for existing providers with valid emails" do
      expect(provider_user_details).to eq([
        {
          provider_id: other_provider.id,
          first_name: "Sue",
          last_name: "Doe",
          email: "sue_doe@example.com",
        },
      ])
    end
  end
end

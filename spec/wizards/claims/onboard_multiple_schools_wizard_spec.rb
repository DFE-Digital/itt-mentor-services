require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard, type: :model do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:state) { {} }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when the csv contains is valid" do
      it { is_expected.to eq(%i[upload confirmation]) }
    end

    context "when the csv contains invalid inputs" do
      let(:csv_content) do
        "name,urn\r\n" \
        "A school,"
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

  describe "#onboard_schools" do
    subject(:onboard_schools) { wizard.onboard_schools }

    let(:school) { create(:school, name: "London School", urn: 111_111) }
    let(:state) do
      {
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end

    before { school }

    context "when the steps are valid" do
      let(:csv_content) do
        "name,urn\r\n" \
        "London School,111111"
      end

      it "queues a job to update the claim with the ESFA response" do
        expect { onboard_schools }.to have_enqueued_job(
          Claims::School::OnboardSchoolsJob,
        ).exactly(:once)
      end
    end

    context "when a step is invalid" do
      context "when the a step is invalid" do
        let(:csv_content) { nil }

        it "returns an invalid wizard error" do
          expect { onboard_schools }.to raise_error("Invalid wizard state")
        end
      end

      context "when the uploaded content includes an invalid input" do
        let(:csv_content) do
          "name,urn\r\n" \
          "London School,333333"
        end

        it "returns an invalid wizard error" do
          expect { onboard_schools }.to raise_error("Invalid wizard state")
        end
      end
    end
  end
end

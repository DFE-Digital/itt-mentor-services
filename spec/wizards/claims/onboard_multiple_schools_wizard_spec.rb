require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard, type: :model do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:state) { {} }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no current or upcoming claim windows" do
      it { is_expected.to eq(%i[no_claim_window]) }
    end

    context "when there a current or upcoming claim windows" do
      let(:current_claim_window) { create(:claim_window, :current) }

      before { current_claim_window }

      context "when the csv contains is valid" do
        it { is_expected.to eq(%i[claim_window upload confirmation]) }
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

        # Temp removed to make the CSV upload work
        # it { is_expected.to eq(%i[claim_window upload upload_errors]) }
        it { is_expected.to eq(%i[claim_window upload confirmation]) }
      end
    end
  end

  describe "#onboard_schools" do
    subject(:onboard_schools) { wizard.onboard_schools }

    let(:claim_window) { create(:claim_window, :current) }
    let(:school) { create(:school, name: "London School", urn: 111_111) }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => claim_window.id },
        "upload" => {
          "csv_upload" => nil,
          "csv_content" => csv_content,
        },
      }
    end

    before do
      school
      claim_window
    end

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
          pending "Validation temp removed"
          expect { onboard_schools }.to raise_error("Invalid wizard state")
        end
      end
    end
  end

  describe "#claim_window" do
    subject(:claim_window) { wizard.claim_window }

    let(:current_claim_window) { create(:claim_window, :current) }
    let(:upcoming_claim_window) { create(:claim_window, :upcoming) }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
      }
    end

    before do
      current_claim_window
      upcoming_claim_window
    end

    it "returns the claim window for the id set in the claim window step" do
      expect(claim_window).to eq(current_claim_window)
    end
  end
end

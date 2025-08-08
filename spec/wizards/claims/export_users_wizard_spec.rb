require "rails_helper"

RSpec.describe Claims::ExportUsersWizard do
  subject(:wizard) { described_class.new(params:, state:, current_step: nil) }

  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:state) { {} }
  let!(:claim_window) { create(:claim_window, :current) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when user selects all claim windows" do
      let(:state) do
        {
          "claim_window" => { "selection" => "all" },
          "activity_level" => { "activity_selection" => "all" },
        }
      end

      it { is_expected.to eq %i[claim_window activity_level check_your_answers] }
    end

    context "when user selects specific claim window" do
      let(:state) do
        {
          "claim_window" => { "selection" => "specific" },
          "specific_claim_window" => { "claim_window_id" => claim_window.id },
          "activity_level" => { "activity_selection" => "active" },
        }
      end

      it { is_expected.to eq %i[claim_window specific_claim_window activity_level check_your_answers] }
    end
  end

  describe "#claim_window_selection" do
    context "when selecting all" do
      let(:state) do
        {
          "claim_window" => { "selection" => "all" },
        }
      end

      it "returns 'all'" do
        expect(wizard.claim_window_selection).to eq("all")
      end
    end

    context "when selecting a specific window" do
      let(:state) do
        {
          "claim_window" => { "selection" => "specific" },
          "specific_claim_window" => { "claim_window_id" => claim_window.id },
        }
      end

      it "returns the claim_window_id" do
        expect(wizard.claim_window_selection).to eq(claim_window.id)
      end
    end
  end

  describe "#activity_level" do
    let(:state) do
      {
        "activity_level" => { "activity_selection" => "active" },
      }
    end

    it "returns the selected activity level" do
      expect(wizard.activity_level).to eq("active")
    end
  end
end

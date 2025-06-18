require "rails_helper"

RSpec.describe Claims::AddSchoolWizard do
  subject(:wizard) { described_class.new(current_user:, state:, params:, current_step: nil) }

  let(:current_user) { create(:claims_support_user) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when there are no current or upcoming claim windows" do
      it { is_expected.to eq(%i[no_claim_window]) }
    end

    context "when there a current or upcoming claim windows" do
      let(:current_claim_window) { create(:claim_window, :current) }

      before { current_claim_window }

      context "when an school was selected during the school step" do
        let!(:school) { create(:school) }
        let(:state) do
          {
            "school" => { "id" => school.id, "name" => school.name },
          }
        end

        it { is_expected.to eq %i[school claim_window check_your_answers] }
      end

      context "when an school was not selected during the school step" do
        it { is_expected.to eq %i[school school_options claim_window check_your_answers] }
      end
    end
  end

  describe "#school" do
    subject { wizard.school }

    let(:current_claim_window) { create(:claim_window, :current) }
    let!(:school) { create(:school) }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
        "school" => { "id" => school.id, "name" => school.name },
      }
    end

    it { is_expected.to eq(school) }
  end

  describe "#onboard_school" do
    let(:current_claim_window) { create(:claim_window, :current) }
    let!(:school) { create(:school) }
    let(:state) do
      {
        "claim_window" => { "claim_window_id" => current_claim_window.id },
        "school" => { "id" => school.id, "name" => school.name },
      }
    end

    it "onboards the school into the claims service" do
      expect(school.claims_service).to be(false)
      expect { wizard.onboard_school }.to change(Claims::School, :count).by(1)
        .and change(Claims::Eligibility, :count).by(1)

      school.reload
      expect(school.manually_onboarded_by).to eq(current_user)
      expect(school.claims_service).to be(true)
      expect(current_claim_window.eligible_schools.ids).to contain_exactly(school.id)
    end
  end
end

require "rails_helper"

RSpec.describe Claims::AddSchoolWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "when an school was selected during the school step" do
      let!(:school) { create(:school) }
      let(:state) do
        {
          "school" => { "id" => school.id, "name" => school.name },
        }
      end

      it { is_expected.to eq %i[school check_your_answers] }
    end

    context "when an school was not selected during the school step" do
      it { is_expected.to eq %i[school school_options check_your_answers] }
    end
  end

  describe "#school" do
    subject { wizard.school }

    let!(:school) { create(:school) }
    let(:state) do
      {
        "school" => { "id" => school.id, "name" => school.name },
      }
    end

    it { is_expected.to eq(school) }
  end

  describe "#onboard_school" do
    let!(:school) { create(:school) }
    let(:state) do
      {
        "school" => { "id" => school.id, "name" => school.name },
      }
    end

    it "onboards the school into the claims service" do
      expect(school.claims_service).to be(false)
      wizard.onboard_school
      school.reload
      expect(school.claims_service).to be(true)
    end
  end
end

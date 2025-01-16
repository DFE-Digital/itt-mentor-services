require "rails_helper"

RSpec.describe Claims::ProviderRejectedClaimWizard do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:claim) { create(:claim) }
  let(:current_user) { create(:claims_support_user) }
  let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
  let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
  let(:mentor_training_1) { create(:mentor_training, claim:, mentor: mentor_jane_doe) }
  let(:mentor_training_2) { create(:mentor_training, claim:, mentor: mentor_john_smith) }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when no mentors have been selected" do
      it { is_expected.to eq(%i[mentor_training check_your_answers]) }
    end

    context "when mentors have been selected" do
      let(:state) do
        {
          "mentor_training" => {
            "mentor_training_ids" => [mentor_training_1.id, mentor_training_2.id],
          },
        }
      end

      before do
        mentor_training_1
        mentor_training_2
      end

      it do
        expect(steps).to contain_exactly(
          :mentor_training,
          "provider_response_#{mentor_training_1.id}".to_sym,
          "provider_response_#{mentor_training_2.id}".to_sym,
          :check_your_answers,
        )
      end
    end
  end

  describe "#submit_provider_responses" do
    subject(:submit_provider_responses) { wizard.submit_provider_responses }

    context "when a step is invalid" do
      let(:state) do
        {
          "mentor_training" => {
            "mentor_training_ids" => nil,
          },
        }
      end

      it "returns an invalid wizard error" do
        expect { submit_provider_responses }.to raise_error("Invalid wizard state")
      end
    end

    context "when all steps are valid" do
      let(:state) do
        {
          "mentor_training" => {
            "mentor_training_ids" => [mentor_training_1.id],
          },
          "provider_response_#{mentor_training_1.id}" => {
            "mentor_training_id" => mentor_training_1.id,
            "reason_not_assured" => "Some reason",
          },
        }
      end

      before do
        mentor_training_1
        mentor_training_2
      end

      it "changes the status of the claim to 'sampling_provider_not_approved',
        and updates the mentor trainings to not assured" do
        submit_provider_responses
        expect(claim.reload.status).to eq("sampling_provider_not_approved")
        expect(mentor_training_1.reload.not_assured).to be(true)
        expect(mentor_training_1.reload.reason_not_assured).to eq("Some reason")
        expect(mentor_training_2.reload.not_assured).to be(false)
      end

      it "creates a claim activity record" do
        expect { submit_provider_responses }.to change(Claims::ClaimActivity, :count).by(1)
        expect(Claims::ClaimActivity.last.action).to eq("rejected_by_provider")
        expect(Claims::ClaimActivity.last.user).to eq(current_user)
        expect(Claims::ClaimActivity.last.record).to eq(claim)
      end
    end
  end

  describe "#mentor_trainings" do
    subject(:mentor_trainings) { wizard.mentor_trainings }

    before do
      mentor_training_1
      mentor_training_2
    end

    it "returns a list of mentor trainings associated with the claim" do
      expect(mentor_trainings).to eq([mentor_training_1, mentor_training_2])
    end
  end

  describe "#selected_mentor_trainings" do
    subject(:selected_mentor_trainings) { wizard.selected_mentor_trainings }

    context "when mentors have not been selected" do
      it "returns an empty array" do
        expect(selected_mentor_trainings).to eq([])
      end
    end

    context "when mentors have been selected" do
      let(:state) do
        {
          "mentor_training" => {
            "mentor_training_ids" => [mentor_training_1.id],
          },
        }
      end

      before do
        mentor_training_1
        mentor_training_2
      end

      it "returns a list of mentor trainings selected in the mentor training step" do
        expect(selected_mentor_trainings).to eq([mentor_training_1])
      end
    end
  end

  describe "#step_name_for_provider_response" do
    let(:state) do
      {
        "mentor_training" => {
          "mentor_training_ids" => [mentor_training_1.id],
        },
      }
    end

    before do
      mentor_training_1
      mentor_training_2
    end

    it "returns the step name for the provider response step associated with a mentor training" do
      expect(wizard.step_name_for_provider_response(mentor_training_1)).to eq(
        "provider_response_#{mentor_training_1.id}".to_sym,
      )
    end
  end
end

require "rails_helper"

RSpec.describe Claims::RejectClaimWizard do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:claim) { create(:claim) }
  let(:current_user) { create(:claims_support_user) }
  let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
  let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
  let(:mentor_training_1) do
    create(:mentor_training,
           claim:,
           mentor: mentor_jane_doe,
           not_assured: true,
           reason_not_assured: "Some reason")
  end
  let(:mentor_training_2) do
    create(:mentor_training,
           claim:,
           mentor: mentor_john_smith,
           not_assured: true,
           reason_not_assured: "Another reason")
  end

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when no mentors have been selected" do
      it { is_expected.to eq(%i[check_your_answers]) }
    end

    context "when the claim has mentor trainings which are assured" do
      before { create(:mentor_training, claim:, mentor: mentor_jane_doe) }

      it { is_expected.to eq(%i[check_your_answers]) }
    end

    context "when the claim has not assured mentor trainings" do
      before do
        mentor_training_1
        mentor_training_2
      end

      it do
        expect(steps).to contain_exactly(
          "school_response_#{mentor_training_1.id}".to_sym,
          "school_response_#{mentor_training_2.id}".to_sym,
          :check_your_answers,
        )
      end
    end
  end

  describe "#reject_claim" do
    subject(:reject_claim) { wizard.reject_claim }

    context "when a step is invalid" do
      let(:state) do
        {
          "school_response_#{mentor_training_1.id}" => {
            "mentor_training_id" => nil,
            "reason_rejected" => nil,
          },
        }
      end

      it "returns an invalid wizard error" do
        expect { reject_claim }.to raise_error("Invalid wizard state")
      end
    end

    context "when all steps are valid" do
      let(:state) do
        {
          "school_response_#{mentor_training_1.id}" => {
            "mentor_training_id" => mentor_training_1.id,
            "reason_rejected" => "Some reason",
          },
          "school_response_#{mentor_training_2.id}" => {
            "mentor_training_id" => mentor_training_2.id,
            "reason_rejected" => "Another reason",
          },
        }
      end

      before do
        mentor_training_1
        mentor_training_2
      end

      it "changes the status of the claim to 'sampling_not_approved',
        and updates the mentor trainings to rejected" do
        reject_claim
        expect(claim.reload.status).to eq("sampling_not_approved")
        expect(mentor_training_1.reload.rejected).to be(true)
        expect(mentor_training_1.reload.reason_rejected).to eq("Some reason")
        expect(mentor_training_2.reload.not_assured).to be(true)
        expect(mentor_training_2.reload.reason_rejected).to eq("Another reason")
      end

      it "creates a claim activity record" do
        expect { reject_claim }.to change(Claims::ClaimActivity, :count).by(1)
        expect(Claims::ClaimActivity.last.action).to eq("rejected_by_school")
        expect(Claims::ClaimActivity.last.user).to eq(current_user)
        expect(Claims::ClaimActivity.last.record).to eq(claim)
      end
    end
  end

  describe "#not_assured_mentor_trainings" do
    subject(:not_assured_mentor_trainings) { wizard.not_assured_mentor_trainings }

    let(:assured_mentor_training) do
      create(:mentor_training, claim:)
    end

    before do
      mentor_training_1
      mentor_training_2
      assured_mentor_training
    end

    it "returns a list of mentor trainings associated with the claim" do
      expect(not_assured_mentor_trainings).to eq([mentor_training_1, mentor_training_2])
    end
  end

  describe "#step_name_for_school_response" do
    before do
      mentor_training_1
      mentor_training_2
    end

    it "returns the step name for the provider response step associated with a mentor training" do
      expect(wizard.step_name_for_school_response(mentor_training_1)).to eq(
        "school_response_#{mentor_training_1.id}".to_sym,
      )
    end
  end
end

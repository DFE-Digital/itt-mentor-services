require "rails_helper"

RSpec.describe "Support sampling approve wizard", type: :request do
  let(:support_user) { create(:claims_support_user) }
  let(:claim) { create(:claim, :audit_requested) }
  let(:mentor) { create(:claims_mentor, schools: [claim.school]) }

  before do
    sign_in_as support_user
    create(:mentor_training, claim:, mentor:, hours_completed: 10)

    I18n.backend.store_translations(:en, {
      claims: {
        support: {
          claims: {
            samplings: {
              approve: {
                edit: { cancel: "Cancel" },
                update: { success: "Claim updated" },
              },
            },
          },
        },
      },
    })
  end

  describe "GET /support/claims/sampling/claims/:id/approve/new", service: :claims do
    it "redirects to the first step" do
      wizard = instance_double(Claims::ApproveSamplingClaimWizard, first_step: :mentor, setup_state: nil)
      allow(Claims::ApproveSamplingClaimWizard).to receive(:new).and_return(wizard)
      expect(wizard).to receive(:setup_state)

      get new_approve_claims_support_claims_sampling_path(claim), params: { state_key: "approve-state" }

      expect(Claims::ApproveSamplingClaimWizard).to have_received(:new).with(
        hash_including(
          claim: claim,
          current_user: support_user,
          current_step: nil,
          state: {},
          params: kind_of(ActionController::Parameters),
        ),
      )
      expect(response).to redirect_to(
        %r{/support/claims/sampling/claims/#{claim.id}/approve/new/approve-state/mentor\?claim=#{claim.id}},
      )
    end

    it "raises when the claim id is invalid" do
      expect {
        get new_approve_claims_support_claims_sampling_path("not-a-real-id"), params: { state_key: "approve-state" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /support/claims/sampling/claims/:id/approve/new/:state_key/:step", service: :claims do
    it "renders the edit step" do
      get approve_claims_support_claims_sampling_path(claim, state_key: "approve-state", step: :mentor)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cancel")
    end

    it "does not run setup_state when wizard state already exists" do
      wizard = instance_double(Claims::ApproveSamplingClaimWizard, first_step: :mentor, setup_state: nil)
      allow(Claims::ApproveSamplingClaimWizard).to receive(:new) do |args|
        allow(wizard).to receive(:setup_state) { args.fetch(:state)["mentor"] = { "mentor_ids" => %w[1] } }
        wizard
      end
      expect(wizard).to receive(:setup_state).once

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Claims::Support::Claims::Samplings::ApproveController).to receive(:render).with("edit") do |controller|
        controller.head :ok
      end
      # rubocop:enable RSpec/AnyInstance

      get new_approve_claims_support_claims_sampling_path(claim), params: { state_key: "approve-state" }
      get approve_claims_support_claims_sampling_path(claim, state_key: "approve-state", step: :mentor)
    end
  end

  describe "PUT /support/claims/sampling/claims/:id/approve/new/:state_key/:step", service: :claims do
    it "renders edit when save_step is false" do
      wizard = instance_double(
        Claims::ApproveSamplingClaimWizard,
        save_step: false,
        setup_state: nil,
      )
      allow(Claims::ApproveSamplingClaimWizard).to receive(:new).and_return(wizard)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Claims::Support::Claims::Samplings::ApproveController).to receive(:render).with("edit") do |controller|
        controller.head :ok
      end
      # rubocop:enable RSpec/AnyInstance

      put approve_claims_support_claims_sampling_path(claim, state_key: "approve-state", step: :mentor)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to the next step when present" do
      wizard = instance_double(
        Claims::ApproveSamplingClaimWizard,
        save_step: true,
        next_step: :mentor_training_1,
        setup_state: nil,
      )
      allow(Claims::ApproveSamplingClaimWizard).to receive(:new).and_return(wizard)

      put approve_claims_support_claims_sampling_path(claim, state_key: "approve-state", step: :mentor)

      expect(response).to redirect_to(
        %r{/support/claims/sampling/claims/#{claim.id}/approve/new/approve-state/mentor_training_1\?claim=#{claim.id}},
      )
    end

    it "approves and resets state on the final step" do
      wizard = instance_double(
        Claims::ApproveSamplingClaimWizard,
        save_step: true,
        next_step: nil,
        approve_claim: nil,
        reset_state: nil,
        setup_state: nil,
      )
      allow(Claims::ApproveSamplingClaimWizard).to receive(:new).and_return(wizard)

      put approve_claims_support_claims_sampling_path(claim, state_key: "approve-state", step: :check_your_answers)

      expect(wizard).to have_received(:approve_claim)
      expect(wizard).to have_received(:reset_state)
      expect(response).to redirect_to(claims_support_claims_samplings_path)
      expect(flash[:heading]).to eq("Claim updated")
    end
  end
end

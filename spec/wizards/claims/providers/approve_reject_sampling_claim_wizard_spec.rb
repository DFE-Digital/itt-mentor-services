require "rails_helper"

RSpec.describe Claims::Providers::ApproveRejectSamplingClaimWizard, type: :model do
  subject(:wizard) do
    described_class.new(
      claim:,
      current_user:,
      action:,
      state:,
      params:,
      current_step:,
    )
  end

  let(:state) { {} }
  let(:params) { ActionController::Parameters.new({}) }
  let(:current_step) { nil }
  let(:action) { "reject" }
  let(:current_user) { create(:claims_provider_user) }
  let(:school) { create(:claims_school) }
  let(:provider) { create(:claims_provider) }
  let(:claim) { create(:claim, :submitted, provider:, school:, status: "sampling_in_progress") }
  let(:mentor_jane) { create(:claims_mentor, first_name: "Jane", last_name: "Doe", schools: [school]) }
  let(:mentor_john) { create(:claims_mentor, first_name: "John", last_name: "Smith", schools: [school]) }
  let(:mentor_training_jane) { create(:mentor_training, claim:, mentor: mentor_jane, provider:, hours_completed: 10) }
  let(:mentor_training_john) { create(:mentor_training, claim:, mentor: mentor_john, provider:, hours_completed: 15) }

  before do
    mentor_training_jane
    mentor_training_john
  end

  describe "#define_steps" do
    context "when no mentors are selected" do
      it "only has the mentor and check your answers steps" do
        expect(wizard.steps.keys).to eq(%i[mentor check_your_answers])
      end
    end

    context "when mentors are selected" do
      let(:state) { { "mentor" => { "mentor_ids" => [mentor_jane.id] } } }

      it "adds a mentor training step for each selected mentor" do
        expect(wizard.steps.keys).to contain_exactly(
          :mentor,
          :"mentor_training_#{mentor_jane.id}",
          :check_your_answers,
        )
      end
    end
  end

  describe "#setup_state" do
    it "seeds the state with a mentor training entry per mentor" do
      wizard.setup_state

      expect(state).to include(
        "mentor_training_#{mentor_jane.id}" => { mentor_id: mentor_jane.id },
        "mentor_training_#{mentor_john.id}" => { mentor_id: mentor_john.id },
      )
    end

    context "when the action is override" do
      let(:action) { "override" }

      before { mentor_training_jane.update!(not_assured: true, reason_not_assured: "Provider reason", hours_clawed_back: 4) }

      it "preselects the mentors amended by the provider" do
        wizard.setup_state

        expect(state["mentor"]).to eq(mentor_ids: [mentor_jane.id])
      end

      it "prefills the hours and reason from the provider's amendment" do
        wizard.setup_state

        expect(state["mentor_training_#{mentor_jane.id}"]).to include(
          hours_option: "custom",
          custom_hours: 6,
          reason_not_assured: "Provider reason",
        )
      end

      it "prefills removing all hours when the provider removed every hour" do
        mentor_training_jane.update!(hours_clawed_back: 10)
        wizard.setup_state

        expect(state["mentor_training_#{mentor_jane.id}"]).to include(hours_option: "remove_all")
      end
    end
  end

  describe "#process_submission" do
    let(:state) do
      {
        "mentor" => { "mentor_ids" => [mentor_jane.id] },
        "mentor_training_#{mentor_jane.id}" => {
          "mentor_id" => mentor_jane.id,
          "hours_option" => "custom",
          "custom_hours" => "8",
          "reason_not_assured" => "Insufficient evidence",
        },
      }
    end

    context "when the action is approve" do
      let(:action) { "approve" }

      it "marks the claim as paid" do
        expect { wizard.process_submission }.to change { claim.reload.status }.to("paid")
      end

      context "when the current user is a support user" do
        let(:current_user) { create(:claims_support_user) }

        it "records a provider approved audit activity" do
          expect { wizard.process_submission }
            .to change { Claims::ClaimActivity.where(action: "provider_approved_audit", record: claim).count }
            .by(1)
        end
      end

      context "when the current user is a provider user" do
        it "does not record a claim activity" do
          expect { wizard.process_submission }.not_to change(Claims::ClaimActivity, :count)
        end
      end
    end

    context "when the action is reject" do
      it "marks the claim as sampling provider not approved and claws back hours" do
        wizard.process_submission

        expect(claim.reload.status).to eq("sampling_provider_not_approved")
        expect(mentor_training_jane.reload.hours_clawed_back).to eq(2)
        expect(mentor_training_jane.reason_not_assured).to eq("Insufficient evidence")
      end

      context "when the current user is a support user" do
        let(:current_user) { create(:claims_support_user) }

        it "records a rejected by provider activity" do
          expect { wizard.process_submission }
            .to change { Claims::ClaimActivity.where(action: "rejected_by_provider", record: claim).count }
            .by(1)
        end
      end
    end

    context "when the action is override" do
      let(:action) { "override" }
      let(:current_user) { create(:claims_support_user) }

      before { claim.update!(status: :sampling_provider_not_approved, amendment_notification_sent_at: 2.days.ago) }

      it "overrides the hours and requests a clawback" do
        wizard.process_submission

        expect(claim.reload).to have_attributes(status: "clawback_requires_approval", clawback_requested_by: current_user)
        expect(mentor_training_jane.reload.hours_clawed_back).to eq(2)
        expect(mentor_training_jane.reason_clawed_back).to eq("Insufficient evidence")
      end

      it "records amended by support and clawback requested activities" do
        expect { wizard.process_submission }
          .to change { Claims::ClaimActivity.where(record: claim, action: %w[amended_by_support clawback_requested]).count }
          .by(2)
      end

      it "notifies the school users" do
        create(:claims_user, schools: [school])

        expect { wizard.process_submission }.to have_enqueued_job(NotifyRateLimiterJob)
      end

      context "when no hours are clawed back" do
        let(:state) do
          {
            "mentor" => { "mentor_ids" => [mentor_jane.id] },
            "mentor_training_#{mentor_jane.id}" => {
              "mentor_id" => mentor_jane.id,
              "hours_option" => "custom",
              "custom_hours" => "10",
              "reason_not_assured" => "Evidence shows all hours",
            },
          }
        end

        it "moves the claim to paid without notifying the school" do
          expect { wizard.process_submission }.not_to have_enqueued_job(NotifyRateLimiterJob)
          expect(claim.reload).to be_paid
        end
      end
    end

    context "when the action is neither approve nor reject" do
      let(:action) { "unknown_action" }

      it "does not process the submission" do
        expect { wizard.process_submission }.not_to(change { claim.reload.status })
      end
    end

    context "when the wizard state is invalid" do
      let(:state) { { "mentor" => { "mentor_ids" => [] } } }

      it "raises an error" do
        expect { wizard.process_submission }.to raise_error("Invalid wizard state")
      end
    end
  end

  describe "#step_name_for_mentor" do
    it "returns the mentor training step name for the given mentor" do
      expect(wizard.step_name_for_mentor(mentor_jane)).to eq(:"mentor_training_#{mentor_jane.id}")
    end
  end

  describe "MentorTrainingStep" do
    let(:state) do
      {
        "mentor" => { "mentor_ids" => [mentor_jane.id] },
        "mentor_training_#{mentor_jane.id}" => {
          "mentor_id" => mentor_jane.id,
          "hours_option" => "custom",
          "custom_hours" => "8",
          "reason_not_assured" => "Insufficient evidence",
        },
      }
    end
    let(:current_step) { :"mentor_training_#{mentor_jane.id}" }
    let(:step) { wizard.steps[current_step] }

    describe "#mentor" do
      context "when the mentor training exists" do
        it "returns the mentor" do
          expect(step.mentor).to eq(mentor_jane)
        end
      end
    end
  end
end

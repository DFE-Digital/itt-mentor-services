module Claims
  class EditSentClawbackWizard < EditRequestClawbackWizard
    include Rails.application.routes.url_helpers

    def define_steps
      add_step(WarningStep)
      add_step(RequestClawbackWizard::MentorTrainingClawbackStep,
               { mentor_training_id: mentor_training.id },
               :mentor_training_id)
    end

    def update_clawback
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Clawback::ClawbackRequested.call(
        claim:,
        esfa_responses: esfa_responses_for_mentor_trainings,
        update_claim_status: false,
      )
    end

    def audit_log_path
      clawback = Claims::Clawback
        .joins(:claims)
        .where(claims: { id: claim.id })
        .order(:created_at)
        .last

      activity = Claims::ClaimActivity
        .clawback_request_delivered
        .where(record: clawback).last

      claims_support_claims_claim_activity_path(activity)
    end
  end
end

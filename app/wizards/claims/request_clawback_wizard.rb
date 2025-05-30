module Claims
  class RequestClawbackWizard < BaseWizard
    attr_reader :claim, :current_user

    def initialize(claim:, current_user:, params:, state:, current_step: nil)
      @claim = claim
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      mentor_trainings.each do |mentor_training|
        add_step(MentorTrainingClawbackStep,
                 { mentor_training_id: mentor_training.id },
                 :mentor_training_id)
      end
      add_step(CheckYourAnswersStep)
    end

    def mentor_trainings
      @mentor_trainings ||= claim.mentor_trainings.not_assured.order_by_mentor_full_name
    end

    def step_name_for_mentor_training_clawback(mentor_training)
      step_name(MentorTrainingClawbackStep, mentor_training.id)
    end

    def esfa_responses_for_mentor_trainings
      mentor_trainings.map do |mentor_training|
        mentor_training_clawback_step = steps[step_name_for_mentor_training_clawback(mentor_training)]
        {
          id: mentor_training.id,
          number_of_hours: mentor_training_clawback_step.number_of_hours,
          reason_for_clawback: mentor_training_clawback_step.reason_for_clawback,
        }
      end
    end

    def submit_esfa_responses
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Clawback::ClawbackRequested.call(
        claim:,
        esfa_responses: esfa_responses_for_mentor_trainings,
      )
      claim.school_users.each do |user|
        Claims::UserMailer.claim_requires_clawback(claim, user).deliver_later
      end

      Claims::ClaimActivity.create!(action: :clawback_requested, user: current_user, record: claim)
    end
  end
end

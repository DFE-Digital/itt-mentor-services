module Claims
  class EditRequestClawbackWizard < BaseWizard
    attr_reader :claim, :mentor_training_id, :current_user

    def initialize(claim:, current_user:, params:, state:, mentor_training_id:, current_step:)
      @claim = claim
      @current_user = current_user
      @mentor_training_id = mentor_training_id
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(RequestClawbackWizard::MentorTrainingClawbackStep,
               { mentor_training_id: mentor_training.id },
               :mentor_training_id)
    end

    def mentor_training
      @mentor_training ||= mentor_trainings.find(mentor_training_id)
    end

    def mentor_trainings
      claim.mentor_trainings.not_assured
    end

    def step_name_for_mentor_training_clawback(mentor_training)
      step_name(RequestClawbackWizard::MentorTrainingClawbackStep, mentor_training.id)
    end

    def update_clawback
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Clawback::ClawbackRequested.call(
        claim:,
        esfa_responses: esfa_responses_for_mentor_trainings,
      )

      Claims::ClaimActivity.create!(action: :clawback_requested, user: current_user, record: claim)
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

    def setup_state
      state[step_name_for_mentor_training_clawback(mentor_training).to_s] = {
        "number_of_hours" => mentor_training.hours_clawed_back,
        "reason_for_clawback" => mentor_training.reason_clawed_back,
      }
    end
  end
end

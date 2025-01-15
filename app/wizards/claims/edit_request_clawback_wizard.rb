module Claims
  class EditRequestClawbackWizard < BaseWizard
    attr_reader :claim, :mentor_training_id

    def initialize(claim:, params:, state:, mentor_training_id:, current_step:)
      @claim = claim
      @mentor_training_id = mentor_training_id
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(RequestClawbackWizard::MentorTrainingClawbackStep,
               { mentor_training_id: mentor_training.id },
               :mentor_training_id)
    end

    def mentor_training
      @mentor_training ||= claim.mentor_trainings.not_assured.find(mentor_training_id)
    end

    def mentor_trainings
      claim.mentor_trainings.not_assured
    end

    def step_name_for_mentor_training_clawback(mentor_training)
      step_name(RequestClawbackWizard::MentorTrainingClawbackStep, mentor_training.id)
    end

    def update_clawback
      raise "Invalid wizard state" unless valid?

      mentor_training.update!(
        hours_clawed_back: steps[step_name_for_mentor_training_clawback(mentor_training)].number_of_hours,
        reason_clawed_back: steps[step_name_for_mentor_training_clawback(mentor_training)].reason_for_clawback,
      )
    end

    def setup_state
      state[step_name_for_mentor_training_clawback(mentor_training).to_s] = {
        "number_of_hours" => mentor_training.hours_clawed_back,
        "reason_for_clawback" => mentor_training.reason_clawed_back,
      }
    end
  end
end

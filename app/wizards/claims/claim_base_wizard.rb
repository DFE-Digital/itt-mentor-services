module Claims
  class ClaimBaseWizard < BaseWizard
    def total_hours
      mentor_training_steps.map(&:hours_completed).sum
    end

    def step_name_for_mentor(mentor)
      step_name(::Claims::AddClaimWizard::MentorTrainingStep, mentor.id)
    end

    private

    def mentor_training_steps
      steps.values.select { |step| step.is_a?(::Claims::AddClaimWizard::MentorTrainingStep) }
    end
  end
end

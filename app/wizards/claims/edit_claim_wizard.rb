module Claims
  class EditClaimWizard < ClaimBaseWizard
    attr_reader :school, :created_by, :claim

    def initialize(school:, claim:, created_by:, params:, state:, current_step: nil)
      @school = school
      @claim = claim
      @created_by = created_by
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(AddClaimWizard::ProviderStep)
      add_step(AddClaimWizard::MentorStep)
      selected_mentors.each do |mentor|
        add_step(AddClaimWizard::MentorTrainingStep, { mentor_id: mentor.id })
      end
      add_step(AddClaimWizard::CheckYourAnswersStep)
      # add_step(NoMentorsStep)
    end

    def selected_mentors
      steps.fetch(:mentor).selected_mentors.presence || claim.mentors
    end

    def academic_year
      claim.claim_window.academic_year
    end

    def update_claim
      raise "Invalid wizard state" unless valid?
    end

    def setup_state
      state["provider"] = { "id" => claim.provider_id }
      state["mentor"] = { "mentor_ids" => claim.mentors.ids }
      claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
        step_name = "mentor_training_#{mentor_training.mentor_id}"
        max_hours = Claims::TrainingAllowance.new(
          mentor: mentor_training.mentor,
          provider: mentor_training.provider,
          academic_year: claim.claim_window.academic_year,
          claim_to_exclude: claim,
        ).remaining_hours
        is_custom_hours = max_hours != mentor_training.hours_completed

        state[step_name] = {
          mentor_id: mentor_training.mentor_id,
          hours_completed: is_custom_hours ? "custom" : mentor_training.hours_completed,
          custom_hours_completed: is_custom_hours ? mentor_training.hours_completed : nil,
        }
      end
    end
  end
end

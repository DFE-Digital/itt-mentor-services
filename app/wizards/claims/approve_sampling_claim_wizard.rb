module Claims
  class ApproveSamplingClaimWizard < ClaimBaseWizard
    attr_reader :claim, :current_user

    def initialize(claim:, current_user:, params:, state:, current_step: nil)
      @claim = claim
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    delegate :reference, to: :claim, prefix: true
    delegate :name, :region_funding_available_per_hour, to: :school, prefix: true
    delegate :name, to: :provider, prefix: true
    delegate :name, to: :academic_year, prefix: true

    def define_steps
      add_step(MentorStep)
      steps.fetch(:mentor).selected_mentors.each do |mentor|
        add_step(MentorTrainingStep, { mentor_id: mentor.id }, :mentor_id)
      end
      add_step(CheckYourAnswersStep)
    end

    def approve_claim
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Sampling::Paid.call(claim:)
      Claims::ClaimActivity.create!(action: :approved_by_support, user: current_user, record: claim)
    end

    def mentor_trainings
      @mentor_trainings ||= claim.mentor_trainings.includes(:mentor, :provider).order_by_mentor_full_name
    end

    def setup_state
      state["mentor"] = { "mentor_ids" => claim.mentors.ids }
      claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
        step_name = "mentor_training_#{mentor_training.mentor_id}"
        state[step_name] = {
          mentor_id: mentor_training.mentor_id,
          hours_completed: mentor_training.hours_completed,
        }
      end
    end

    def provider
      claim.provider
    end
  end
end

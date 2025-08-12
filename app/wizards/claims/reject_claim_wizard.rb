module Claims
  class RejectClaimWizard < BaseWizard
    attr_reader :claim, :current_user

    def initialize(claim:, current_user:, params:, state:, current_step: nil)
      @claim = claim
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      not_assured_mentor_trainings.each do |mentor_training|
        add_step(SchoolResponseStep,
                 { mentor_training_id: mentor_training.id },
                 :mentor_training_id)
      end
      add_step(CheckYourAnswersStep)
    end

    def reject_claim
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Sampling::NotApproved.call(
        claim:,
        school_responses: school_responses_for_mentor_trainings,
      )

      Claims::ClaimActivity.create!(action: :rejected_by_school, user: current_user, record: claim)
    end

    def not_assured_mentor_trainings
      @not_assured_mentor_trainings ||= claim.mentor_trainings
        .includes(:mentor, :provider)
        .not_assured
        .order_by_mentor_full_name
    end

    def step_name_for_school_response(mentor_training)
      step_name(SchoolResponseStep, mentor_training.id)
    end

    private

    def school_responses_for_mentor_trainings
      not_assured_mentor_trainings.map do |mentor_training|
        school_response_step = steps[step_name_for_school_response(mentor_training)]
        {
          id: mentor_training.id,
          rejected: true,
          reason_rejected: school_response_step.reason_rejected,
        }
      end
    end
  end
end

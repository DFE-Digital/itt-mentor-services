module Claims
  class ProviderRejectedClaimWizard < BaseWizard
    attr_reader :claim, :current_user

    def initialize(claim:, current_user:, params:, state:, current_step: nil)
      @claim = claim
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(MentorTrainingStep)
      selected_mentor_trainings.each do |mentor_training|
        add_step(ProviderResponseStep,
                 { mentor_training_id: mentor_training.id },
                 :mentor_training_id)
      end
      add_step(CheckYourAnswersStep)
    end

    def submit_provider_responses
      raise "Invalid wizard state" unless valid?

      Claims::Claim::Sampling::ProviderNotApproved.call(
        claim:,
        provider_responses: provider_responses_for_mentor_trainings,
      )

      Claims::ClaimActivity.create!(action: :rejected_by_provider, user: current_user, record: claim)
    end

    def mentor_trainings
      @mentor_trainings ||= claim.mentor_trainings.includes(:mentor).order_by_mentor_full_name
    end

    def selected_mentor_trainings
      return [] if steps.fetch(:mentor_training).mentor_training_ids.blank?

      mentor_trainings.where(
        id: steps.fetch(:mentor_training).mentor_training_ids,
      )
    end

    def step_name_for_provider_response(mentor_training)
      step_name(ProviderResponseStep, mentor_training.id)
    end

    private

    def provider_responses_for_mentor_trainings
      mentor_trainings.includes(:provider).map do |mentor_training|
        provider_response_step = steps[step_name_for_provider_response(mentor_training)]
        {
          id: mentor_training.id,
          not_assured: provider_response_step.present?,
          reason_not_assured: provider_response_step&.reason_not_assured,
        }
      end
    end
  end
end

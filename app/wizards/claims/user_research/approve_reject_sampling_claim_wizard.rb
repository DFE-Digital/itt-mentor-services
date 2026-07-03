module Claims
  module UserResearch
    class ApproveRejectSamplingClaimWizard < BaseWizard
      attr_reader :claim, :current_user, :action

      def initialize(claim:, current_user:, action:, params:, state:, current_step: nil)
        @claim = claim
        @current_user = current_user
        @action = action
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

      def process_submission
        raise "Invalid wizard state" unless valid?

        if action == "approve"
          Claims::Claim::Sampling::Paid.call(claim:)
          create_claim_activity(:approved_by_provider)
        elsif action == "reject"
          Claims::Claim::Sampling::ProviderNotApproved.call(
            claim:,
            provider_responses: provider_responses_for_mentor_trainings,
          )
          create_claim_activity(:rejected_by_provider)
        end
      end

      def mentor_trainings
        @mentor_trainings ||= claim.mentor_trainings.includes(:mentor, :provider).order_by_mentor_full_name
      end

      def setup_state
        claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
          step_name = "mentor_training_#{mentor_training.mentor_id}"
          state[step_name] = {
            mentor_id: mentor_training.mentor_id,
          }
        end
      end

      def provider
        claim.provider
      end

      def school
        claim.school
      end

      def academic_year
        claim.claim_window.academic_year
      end

      def step_name_for_mentor(mentor)
        step_name(MentorTrainingStep, mentor.id)
      end

      private

      def create_claim_activity(action_name)
        return unless current_user.is_a?(Claims::SupportUser)

        Claims::ClaimActivity.create!(action: action_name, user: current_user, record: claim)
      end

      def provider_responses_for_mentor_trainings
        mentor_trainings.map do |mentor_training|
          step_name_value = step_name(MentorTrainingStep, mentor_training.mentor_id)
          mentor_training_step = steps[step_name_value]
          {
            id: mentor_training.id,
            not_assured: mentor_training_step.present?,
            reason_not_assured: mentor_training_step&.reason_not_assured,
            hours_clawed_back: mentor_training_step.present? ? [mentor_training.hours_completed.to_i - mentor_training_step.completed_hours, 0].max : nil,
          }
        end
      end
    end
  end
end

module Claims
  class ClawbackSupportApprovalWizard < BaseWizard
    attr_reader :claim, :current_user

    def initialize(claim:, current_user:, params:, state:, current_step: nil)
      @claim = claim
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    delegate :reference, to: :claim, prefix: true

    def define_steps
      mentor_trainings.each do |mentor_training|
        add_step(ApprovalStep,
                 { mentor_training_id: mentor_training.id },
                 :mentor_training_id)
      end
      add_step(CheckYourAnswersStep)
    end

    def approve_clawback
      raise "Invalid wizard state" unless valid?

      if all_approved?
        claim.update!(
          status: :clawback_requested,
          clawback_approved_by: current_user,
        )
      else
        mentor_trainings.each do |mentor_training|
          reason_clawback_rejected = steps.fetch(
            step_name_for_approval(mentor_training),
          ).reason_clawback_rejected
          mentor_training.update!(reason_clawback_rejected:)
        end
        claim.update!(status: :clawback_rejected)
      end
    end

    def mentor_trainings
      @mentor_trainings ||= claim
                              .mentor_trainings
                              .includes(:mentor)
                              .not_assured
                              .order_by_mentor_full_name
    end

    def step_name_for_approval(mentor_training)
      step_name(ApprovalStep, mentor_training.id)
    end

    private

    def approval_steps
      steps.values.select do |step|
        step.is_a?(ApprovalStep)
      end
    end

    def all_approved?
      approval_steps.map(&:approved).all?(
        ::Claims::ClawbackSupportApprovalWizard::ApprovalStep::YES,
      )
    end
  end
end

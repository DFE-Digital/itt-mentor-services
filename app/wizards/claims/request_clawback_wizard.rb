module Claims
  class RequestClawbackWizard < BaseWizard
    attr_reader :claim

    def initialize(claim:, params:, state:, current_step: nil)
      @claim = claim
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(ClawbackStep)
      add_step(CheckYourAnswersStep)
    end

    def update_status
      @claim.status = :clawback_requested
      @claim.save!
    end
  end
end

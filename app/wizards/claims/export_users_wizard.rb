module Claims
  class ExportUsersWizard < BaseWizard
    def initialize(params:, state:, current_step: nil)
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(ClaimWindowStep)
      add_step(SpecificClaimWindowStep) unless steps[:claim_window].all_claim_windows?
      add_step(ActivityLevelStep)
      add_step(CheckYourAnswersStep)
    end

    def claim_window_selection
      steps[:claim_window].all_claim_windows? ? "all" : steps[:specific_claim_window].claim_window_id
    end

    def activity_level
      steps[:activity_level].activity_selection
    end
  end
end

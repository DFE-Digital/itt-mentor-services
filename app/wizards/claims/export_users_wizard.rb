module Claims
  class ExportUsersWizard < BaseWizard
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

    def generate_csv
      Claims::ExportUsers.call(
        claim_window_id: claim_window_selection,
        activity_level: activity_level,
      )
    end
  end
end

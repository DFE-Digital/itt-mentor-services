module Claims
  class AddSchoolWizard < BaseWizard
    def define_steps
      if claim_windows_exist?
        add_step(SchoolStep)
        add_step(SchoolOptionsStep) if steps.fetch(:school).school.blank?
        add_step(ClaimWindowStep)
        add_step(CheckYourAnswersStep)
      else
        add_step(NoClaimWindowStep)
      end
    end

    def school
      @school ||= (steps[:school_options]&.school ||
          steps[:school].school).decorate
    end

    def onboard_school
      school.update!(claims_service: true)
      school.becomes(Claims::School)
        .eligibilities
        .create!(claim_window:)
    end

    def claim_window
      @claim_window = Claims::ClaimWindow.find(
        steps.fetch(:claim_window).claim_window_id,
      )
    end

    private

    def claim_windows_exist?
      Claims::ClaimWindow.current.present? ||
        Claims::ClaimWindow.next.present?
    end
  end
end

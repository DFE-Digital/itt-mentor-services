module Claims
  class AddSchoolWizard < BaseWizard
    def define_steps
      add_step(SchoolStep)
      add_step(SchoolOptionsStep) if steps.fetch(:school).school.blank?
      add_step(CheckYourAnswersStep)
    end

    def school
      @school ||= (steps[:school_options]&.school ||
          steps[:school].school).decorate
    end

    def onboard_school
      school.update!(claims_service: true)
      claim_window = Claims::ClaimWindow.current
      return if claim_window.blank?

      school
        .becomes(Claims::School)
        .eligibilities
        .create!(claim_window:)
    end
  end
end

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
    end
  end
end

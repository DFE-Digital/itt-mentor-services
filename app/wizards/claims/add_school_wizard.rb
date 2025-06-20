module Claims
  class AddSchoolWizard < BaseWizard
    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      if claim_windows_exist?
        add_step(SchoolStep)
        add_step(SchoolOptionsStep) if steps.fetch(:school).school.blank?
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
      school.update!(claims_service: true, manually_onboarded_by: current_user)
      school.becomes(Claims::School)
        .eligibilities
        .create!(claim_window:)
    end

    def claim_window
      @claim_window = Claims::ClaimWindow.current
    end

    private

    attr_reader :current_user

    def claim_windows_exist?
      Claims::ClaimWindow.current.present? ||
        Claims::ClaimWindow.next.present?
    end
  end
end

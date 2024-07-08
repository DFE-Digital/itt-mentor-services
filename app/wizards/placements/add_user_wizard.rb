module Placements
  class AddUserWizard < BaseWizard
    def initialize(organisation:, params:, session:, current_step: nil)
      @organisation = organisation
      super(session:, params:, current_step:)
    end

    def define_steps
      add_step(UserStep)
      add_step(CheckYourAnswersStep)
    end
  end
end

module Claims
  class AddUserWizard < BaseWizard
    attr_reader :organisation

    def initialize(organisation:, params:, state:, current_step: nil)
      @organisation = organisation
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(UserStep)
      add_step(CheckYourAnswersStep)
    end

    def create_user
      raise "Invalid wizard state" unless valid?

      user.save!
      user
    end

    private

    def user
      steps[:user].user
    end
  end
end

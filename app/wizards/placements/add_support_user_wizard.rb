module Placements
  class AddSupportUserWizard < BaseWizard
    def define_steps
      add_step(SupportUserStep)
      add_step(CheckYourAnswersStep)
    end

    def create_support_user
      raise "Invalid wizard state" unless valid?

      support_user.undiscard! if support_user.discarded?
      support_user.save!
      support_user
    end

    private

    def support_user
      @support_user ||= steps[:support_user].support_user
    end
  end
end

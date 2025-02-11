module Claims
  class SupportDetailsWizard < BaseWizard
    attr_reader :claim

    def initialize(claim:, params:, state:, current_step: nil)
      @claim = claim

      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(ZendeskStep) if current_step == :zendesk
      add_step(SupportUserStep) if current_step == :support_user
    end

    def update_support_details
      raise "Invalid wizard state" unless valid?

      if steps[:zendesk].present?
        claim.zendesk_url = steps[:zendesk].zendesk_url
      else
        claim.support_user_id = steps[:support_user].support_user_id
      end

      claim.save!
    end

    def setup_state
      if steps[:zendesk].present?
        state["zendesk"] = { "zendesk_url" => claim.zendesk_url }
      else
        state["support_user"] = { "support_user_id" => claim.support_user_id }
      end
    end

    def success_message
      return I18n.t(".wizards.claims.support_details_wizard.success.zendesk") if steps[:zendesk].present?

      I18n.t(".wizards.claims.support_details_wizard.success.support_user")
    end
  end
end

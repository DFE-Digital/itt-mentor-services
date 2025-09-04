module Claims
  class SubmitClaimsToBePaidWizard < BaseWizard
    attr_reader :current_user

    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      if claims_awaiting_payment?
        add_step(SelectClaimWindowStep)
        add_step(CheckYourAnswersStep)
      else
        add_step(NoClaimsToPayStep)
      end
    end

    def pay_claims
      raise "Invalid wizard state" unless valid?

      Claims::Payment::CreateAndDeliverJob.perform_later(
        current_user_id: current_user.id,
        claim_window_id: claim_window.id,
      )
    end

    private

    def claims_awaiting_payment?
      Claims::Claim.submitted.exists?
    end

    def claim_window
      Claims::ClaimWindow.find(steps[:select_claim_window].claim_window)
    end
  end
end

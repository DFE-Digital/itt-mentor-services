class Claims::Support::Claim::ActionsComponent < ApplicationComponent
  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    tag.div(class: "claim-actions") do
      render_actions
    end
  end

  private

  attr_reader :claim

  def render_actions
    case claim.status
    when *Claims::Claim::PAYMENT_ACTIONABLE_STATUSES
      render "claims/support/claims/payments/claims/actions", claim:
    when *Claims::Claim::SAMPLING_STATUSES
      render "claims/support/claims/samplings/actions", claim:
    when *Claims::Claim::CLAWBACK_STATUSES
      render "claims/support/claims/clawbacks/actions", claim:
    end
  end
end

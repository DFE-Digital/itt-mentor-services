class Claims::Support::ApplicationController < Claims::ApplicationController
  append_pundit_namespace :support

  before_action :authorize_user!

  private

  def load_claim_history
    @pagy, @claim_status_changes = pagy(Claims::ClaimStatusChangesQuery.call(claim: @claim))
  end

  def authorize_user!
    return if current_user.support_user?

    redirect_to sign_in_path, flash: {
      heading: t("you_cannot_perform_this_action"),
      success: false,
    }
  end

  def support_controller?
    true
  end
end

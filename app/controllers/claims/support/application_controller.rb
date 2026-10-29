class Claims::Support::ApplicationController < Claims::ApplicationController
  append_pundit_namespace :support

  before_action :authorize_user!

  private

  def load_claim_history
    @claim_status_history_enabled = Flipper.enabled?(:claim_status_history)
    if @claim_status_history_enabled
      @pagy, @claim_status_changes = pagy(Claims::ClaimStatusChangesQuery.call(claim: @claim))
    else
      @pagy, @claim_activities = pagy(Claims::ClaimActivitiesForClaimQuery.call(claim: @claim))
      @claim_activities = @claim_activities.decorate
    end
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

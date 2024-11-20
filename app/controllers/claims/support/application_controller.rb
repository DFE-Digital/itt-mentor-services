class Claims::Support::ApplicationController < Claims::ApplicationController
  before_action :authorize_user!

  def authorize(record, query = nil, policy_class: nil)
    super([:support, *unwrap_pundit_scope(record)], query, policy_class:)
  end

  def policy(record)
    super([:support, *unwrap_pundit_scope(record)])
  end

  private

  def pundit_policy_scope(scope)
    super([:support, *unwrap_pundit_scope(scope)])
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

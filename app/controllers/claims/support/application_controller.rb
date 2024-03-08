class Claims::Support::ApplicationController < Claims::ApplicationController
  before_action :authorize_user!

  private

  def authorize_user!
    return if current_user.support_user?

    redirect_to sign_in_path, alert: t("you_cannot_perform_this_action")
  end

  def support_controller?
    true
  end
end

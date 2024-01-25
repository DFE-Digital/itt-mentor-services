class Placements::Support::ApplicationController < ApplicationController
  before_action :authorize_user!

  private

  def authorize_user!
    return if current_user.is_support_user?

    redirect_to placements_root_path, alert: t("you_cannot_perform_this_action")
  end

  def support_controller?
    true
  end
end

class Placements::Support::ApplicationController < ApplicationController
  before_action :authorize_user!

  private

  def authorize_user!
    return if current_user.support_user?

    redirect_to placements_root_path, alert: "You cannot perform this action"
  end

  def support_controller?
    true
  end
end

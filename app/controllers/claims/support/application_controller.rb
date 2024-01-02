class Claims::Support::ApplicationController < ApplicationController
  before_action :authenticate_user!, :authorize_user!

  private

  def authorize_user!
    return if current_user.support_user?

    redirect_to claims_root_path, alert: "You cannot perform this action"
  end
end

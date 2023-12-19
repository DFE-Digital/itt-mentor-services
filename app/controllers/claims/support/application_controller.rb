class Claims::Support::ApplicationController < ApplicationController
  before_action :authenticate_support_user!

  private

  def authenticate_support_user!
    authenticate_user!

    unless current_user.support_user?
      redirect_to claims_root_path, alert: "You cannot perform this action"
    end
  end
end

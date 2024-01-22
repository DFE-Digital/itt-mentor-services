class AccountController < ApplicationController
  def show
    redirect_to root_path if current_user.blank?
  end
end

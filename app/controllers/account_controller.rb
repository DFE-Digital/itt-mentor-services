class AccountController < ApplicationController
  def index
    redirect_to root_path if current_user.blank?
  end
end

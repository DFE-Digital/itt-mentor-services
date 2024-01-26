class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new callback]

  # setup inspired by register-trainee-teacher
  # TODO: Replace with commented code when DfE Sign In implemented

  def new; end

  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      # DfESignInUsers::Update.call(user: current_user, sign_in_user: sign_in_user)

      redirect_to after_sign_in_path
    else
      # session.delete(:requested_path)
      DfESignInUser.end_session!(session)
      # redirect_to(sign_in_user_not_found_path)
    end
  end

  def destroy
    DfESignInUser.end_session!(session)

    redirect_to after_sign_out_path
  end
end

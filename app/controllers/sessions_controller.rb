class SessionsController < ApplicationController
  # setup inspired by register-trainee-teacher
  # TODO: Replace with commented code when DfE Sign In implemented
  
  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])
    if current_user
      # DfESignInUsers::Update.call(user: current_user, sign_in_user: sign_in_user)

      redirect_to(root_path)
    else
      # session.delete(:requested_path)
      DfESignInUser.end_session!(session)
      # redirect_to(sign_in_user_not_found_path)
    end
  end

  def signout
    DfESignInUser.end_session!(session)
    redirect_to root_path
  end
end

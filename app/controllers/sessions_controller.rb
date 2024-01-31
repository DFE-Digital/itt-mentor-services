class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new callback]
  before_action :redirect_to_after_sign_in_path, only: %i[new], if: :user_signed_in?

  def new; end

  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      DfESignIn::UserUpdate.call(current_user:, sign_in_user:)

      redirect_to after_sign_in_path
    else
      DfESignInUser.end_session!(session)
      flash[:alert] = I18n.t(".you_do_not_have_access_to_this_service")
      redirect_to after_sign_out_path
    end
  end

  def destroy
    DfESignInUser.end_session!(session)

    redirect_to after_sign_out_path
  end

  private

  def redirect_to_after_sign_in_path
    redirect_to after_sign_in_path
  end
end

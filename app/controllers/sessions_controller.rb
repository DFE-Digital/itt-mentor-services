class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new callback failure]
  before_action :redirect_to_after_sign_in_path, only: %i[new], if: :user_signed_in?

  def new; end

  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      DfESignIn::UserUpdate.call(current_user:, sign_in_user:)

      set_prototype_persona_session

      redirect_to sign_in_redirect_path
    else
      DfESignInUser.end_session!(session)
      redirect_to after_sign_out_path, flash: {
        heading: I18n.t(".you_do_not_have_access_to_this_service"),
        success: false,
      }
    end
  end

  def destroy
    DfESignInUser.end_session!(session)

    redirect_to sign_in_user.logout_url(request), allow_other_host: true
  end

  def failure
    dfe_sign_in_uid = session.fetch("dfe_sign_in_user", {})["dfe_sign_in_uid"]
    Sentry.capture_message("DSI failure with #{params[:message]} for dfe_sign_in_uid: #{dfe_sign_in_uid}")

    DfESignInUser.end_session!(session)

    redirect_to internal_server_error_path
  end

  private

  def sign_in_redirect_path
    return claims_user_research_provider_claims_path if claims_patricia_persona?

    after_sign_in_path
  end

  def set_prototype_persona_session
    return unless claims_patricia_persona?

    session[:provider_research_code] = "BPN01"
  end

  def claims_patricia_persona?
    current_service == :claims && current_user&.first_name == "Patricia"
  end
end

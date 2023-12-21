class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RoutesHelper

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  helper_method :current_user

  private

  def sign_in_user
    @sign_in_user ||=
      begin
        session["service"] = current_service
        DfESignInUser.load_from_session(session)
      end
  end

  def current_user
    @current_user ||= sign_in_user&.user
  end

  def after_sign_in_path
    if current_user.support_user?
      support_root_path
    elsif current_user.memberships.many?
      organisation_index_path
    else
      root_path
    end
  end

  def after_sign_out_path
    sign_in_path
  end

  def authenticate_user!
    return if current_user

    session[:requested_path] = request.fullpath

    redirect_to sign_in_path
  end
end

class ApplicationController < ActionController::Base
  include ApplicationHelper

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  helper_method :current_user

  private

  def sign_in_user
    session["service"] = current_service
    @sign_in_user ||= DfESignInUser.load_from_session(session)
  end

  def current_user
    @current_user ||= sign_in_user&.user
  end
end

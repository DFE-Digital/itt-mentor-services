class ApplicationController < ActionController::Base
  include ApplicationHelper

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
end

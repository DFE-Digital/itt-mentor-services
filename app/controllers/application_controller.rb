class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include ApplicationHelper
  include RoutesHelper
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  helper_method :current_user, :support_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def sign_in_user
    @sign_in_user ||= DfESignInUser.load_from_session(session, service: current_service)
  end

  def current_user
    @current_user ||= sign_in_user&.user
  end

  def user_signed_in?
    current_user.present?
  end

  def after_sign_in_path
    if requested_path.present?
      requested_path
    elsif current_user.support_user?
      support_root_path
    else
      organisations_path
    end
  end

  def requested_path
    return if [sign_in_path, sign_out_path].include?(session["requested_path"])

    @path ||= session.delete("requested_path")
  end

  def after_sign_out_path
    sign_in_path
  end

  def redirect_to_after_sign_in_path
    redirect_to after_sign_in_path
  end

  def authenticate_user!
    return if current_user

    session["requested_path"] = request.fullpath

    redirect_to sign_in_path
  end

  def support_controller?
    false
  end

  def user_not_authorized
    flash[:alert] = t("you_cannot_perform_this_action")
    can_be_infinite_redirect = request.url == request.referer

    if can_be_infinite_redirect
      redirect_to root_path
    else
      redirect_back(fallback_location: root_path)
    end
  end
end

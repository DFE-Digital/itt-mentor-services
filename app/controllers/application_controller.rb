class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include ApplicationHelper
  include RoutesHelper
  include Pagy::Backend
  include Pundit::Authorization
  include PunditNamespaces

  before_action :authenticate_user!

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  helper_method :current_user, :support_controller?, :policy_scope, :claims_change_organisation_path

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def sign_in_user
    @sign_in_user ||= DfESignInUser.load_from_session(session, service: current_service)
  end

  def current_user
    @current_user ||= sign_in_user&.user
  end

  # Where a claims user goes to choose between their organisations, or nil when
  # they only belong to one. Counts only organisations the user is a member of.
  def claims_change_organisation_path
    schools = claims_school_choices.count
    providers = claims_provider_choices.count
    return unless schools + providers > 1

    providers.positive? && schools.zero? ? claims_providers_path : claims_schools_path
  end

  # The organisations a person can choose between. Each comes from the policy
  # scope of the user record of that type, so only memberships are returned.
  def claims_school_choices
    school_user = sign_in_user.school_user
    return Claims::School.none unless school_user

    Claims::SchoolPolicy::Scope.new(school_user, Claims::School).resolve
  end

  def claims_provider_choices
    provider_user = sign_in_user.provider_user
    return Claims::Provider.none unless provider_user

    Claims::Providers::ProviderPolicy::Scope.new(provider_user, Claims::Provider).resolve
  end

  def user_signed_in?
    current_user.present?
  end

  def after_sign_in_path
    if requested_path.present?
      requested_path
    elsif current_user.support_user?
      support_root_path
    elsif current_service == :claims && current_user.is_a?(Claims::ProviderUser)
      claims_providers_path
    else
      organisations_path
    end
  end

  def requested_path
    return if [sign_in_path, sign_out_path].include?(session["requested_path"])

    @requested_path ||= session.delete("requested_path")
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
    flash[:heading] = t("you_cannot_perform_this_action")
    flash[:success] = false
    can_be_infinite_redirect = request.url == request.referer

    if can_be_infinite_redirect
      redirect_to root_path
    else
      redirect_back(fallback_location: root_path)
    end
  end
end

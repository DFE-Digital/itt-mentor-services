class Claims::Providers::ApplicationController < Claims::ApplicationController
  append_pundit_namespace :providers

  before_action :authorize_user!

  private

  # A person with both a school and a provider record acts as their provider
  # user on provider pages, so provider memberships and policies apply.
  def current_user
    @current_user ||= begin
      user = super
      user.instance_of?(Claims::User) ? sign_in_user.provider_user || user : user
    end
  end

  def authorize_user!
    return if current_user.support_user? || current_user.is_a?(Claims::ProviderUser)

    redirect_to sign_in_path, flash: {
      heading: t("you_cannot_perform_this_action"),
      success: false,
    }
  end

  def set_provider
    @provider = policy_scope(Claims::Provider).find(params.require(:provider_id))
    session[:claims_current_provider_id] = @provider.id
  end
end

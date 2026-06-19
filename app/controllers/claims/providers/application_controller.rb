class Claims::Providers::ApplicationController < Claims::ApplicationController
  append_pundit_namespace :providers

  before_action :authorize_user!

  private

  def authorize_user!
    return if current_user.support_user? || current_user.is_a?(Claims::ProviderUser)

    redirect_to sign_in_path, flash: {
      heading: t("you_cannot_perform_this_action"),
      success: false,
    }
  end

  def set_provider
    @provider = policy_scope(Claims::Provider).find(params.require(:provider_id))
  end
end

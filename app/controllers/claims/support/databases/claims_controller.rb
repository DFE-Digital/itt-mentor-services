class Claims::Support::Databases::ClaimsController < Claims::Support::ApplicationController
  before_action :skip_authorization
  def revert_to_submitted; end

  def update_to_submitted
    Claims::RevertClaimsToSubmitted.call

    redirect_to claims_support_settings_path, flash: {
      heading: t(".success"),
    }
  end
end

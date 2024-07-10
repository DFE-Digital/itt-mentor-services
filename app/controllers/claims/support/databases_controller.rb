class Claims::Support::DatabasesController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def destroy
    Claims::ResetDatabase.call

    redirect_to claims_support_settings_path, flash: { success: "Database has been reset" }
  end
end

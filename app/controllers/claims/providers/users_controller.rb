class Claims::Providers::UsersController < Claims::Providers::ApplicationController
  before_action :set_provider
  before_action :set_user, only: %i[show remove destroy]
  before_action :authorize_user

  def index
    @pagy, @users = pagy(@provider.users.order_by_full_name)
  end

  def show; end

  def remove; end

  def destroy
    User::Remove.call(user: @user, organisation: @provider)

    redirect_to claims_provider_users_path(@provider), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_user
    @user = @provider.users.find(params.require(:id))
  end

  def authorize_user
    authorize @user || Claims::ProviderUser
  end
end

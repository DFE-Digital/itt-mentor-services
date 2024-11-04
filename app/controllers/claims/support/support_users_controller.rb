class Claims::Support::SupportUsersController < Claims::Support::ApplicationController
  before_action :set_support_user, only: %i[show remove destroy]
  before_action :authorize_support_user

  def index
    @pagy, @support_users = pagy(Claims::SupportUser.order_by_full_name)
  end

  def show; end

  def remove; end

  def destroy
    SupportUser::Remove.call(support_user: @support_user)

    redirect_to claims_support_support_users_path, flash: {
      heading: t(".success"),
    }
  end

  private

  def set_support_user
    @support_user = Claims::SupportUser.find(params.require(:id))
  end

  def authorize_support_user
    authorize @support_user || Claims::SupportUser
  end
end

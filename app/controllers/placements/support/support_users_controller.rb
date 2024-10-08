class Placements::Support::SupportUsersController < Placements::ApplicationController
  before_action :set_support_user, only: %i[show remove destroy]
  before_action :authorize_support_user, only: %i[remove destroy]

  def index
    scope = policy_scope(Placements::SupportUser)
    @support_users = scope.order_by_full_name
  end

  def show; end

  def remove; end

  def destroy
    SupportUser::Remove.call(support_user: @support_user)
    redirect_to placements_support_support_users_path, flash: {
      heading: t(".success_heading"),
    }
  end

  private

  def set_support_user
    @support_user = Placements::SupportUser.find(params.require(:id))
  end

  def authorize_support_user
    authorize @support_user
  end
end

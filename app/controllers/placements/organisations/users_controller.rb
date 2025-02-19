class Placements::Organisations::UsersController < Placements::ApplicationController
  before_action :set_organisation
  before_action :set_user, only: %i[show remove destroy]
  before_action :set_user_membership, only: %i[show remove destroy]
  before_action :authorize_user, only: %i[remove destroy]

  def index
    @users = users.order_by_full_name
  end

  def show; end

  def remove; end

  def destroy
    User::Remove.call(user: @user, organisation: @organisation)
    flash[:heading] = t(".user_deleted")
    redirect_to_index
  end

  private

  def set_user
    @user = users.find(params.require(:id))
  end

  def users
    policy_scope(@organisation.users)
  end

  def set_user_membership
    @user_membership = @user.user_memberships.find_by!(organisation: @organisation)
  end

  def authorize_user
    authorize @user_membership
  end
end

class Claims::Schools::UsersController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_user, only: %i[show remove destroy]
  before_action :authorize_user

  def index
    @pagy, @users = pagy(@school.users.order_by_full_name)
  end

  def show; end

  def remove; end

  def destroy
    User::Remove.call(user: @user, organisation: @school)

    redirect_to claims_school_users_path(@school), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_user
    @user = @school.users.find(params.require(:id))
  end

  def authorize_user
    authorize @user || Claims::User
  end
end

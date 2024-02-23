class Claims::Support::Schools::UsersController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_user, only: %i[show remove destroy]
  before_action :authorize_user

  def index
    @users = @school.users
  end

  def new
    @user_form = params[:user_invite_form].present? ? user_form : UserInviteForm.new
  end

  def check
    render :new unless user_form.valid?
  end

  def create
    user_form.save!

    User::Invite.call(user: user_form.user, organisation: @school)

    redirect_to claims_support_school_users_path(@school), flash: { success: t(".success") }
  end

  def show; end

  def remove; end

  def destroy
    User::Remove.call(user: @user, organisation: @school)

    redirect_to claims_support_school_users_path(@school), flash: { success: t(".success") }
  end

  private

  def user_params
    params.require(:user_invite_form)
          .permit(:first_name, :last_name, :email)
          .merge({ service: current_service, organisation: @school })
  end

  def set_user
    @user = @school.users.find(params.require(:id))
  end

  def user_form
    @user_form ||= UserInviteForm.new(user_params)
  end

  def authorize_user
    authorize @user || Claims::User
  end
end

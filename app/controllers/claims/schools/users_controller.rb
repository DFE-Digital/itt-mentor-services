class Claims::Schools::UsersController < ApplicationController
  include Claims::BelongsToSchool

  def index
    @users = @school.users
  end

  def show
    @user = @school.users.find(params.require(:id))
  end

  def new
    @user_form = params[:user_invite_form].present? ? user_form : UserInviteForm.new
  end

  def check
    render :new unless user_form.valid?
  end

  def create
    user_form.save!
    UserInviteService.call(user_form.user, @school)
    redirect_to claims_school_users_path(@school), flash: { success: t(".user_added") }
  end

  private

  def user_params
    params.require(:user_invite_form)
          .permit(:first_name, :last_name, :email)
          .merge({ service: current_service, organisation: @school })
  end

  def user_form
    @user_form ||= UserInviteForm.new(user_params)
  end
end

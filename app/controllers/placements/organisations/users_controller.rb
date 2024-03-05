class Placements::Organisations::UsersController < ApplicationController
  before_action :set_organisation
  before_action :set_user, only: %i[show remove destroy]
  before_action :redirect_if_not_allowed, only: %i[remove destroy]

  def index
    @users = users.order_by_full_name
  end

  def show; end

  def new
    @user_form = params[:user_invite_form].present? ? user_form : UserInviteForm.new
  end

  def check
    render :new unless user_form.valid?
  end

  def create
    user_form.save!
    User::Invite.call(user: user_form.user, organisation: @organisation)
    redirect_to_index
    flash[:success] = t(".user_added")
  end

  def remove; end

  def destroy
    User::Remove.call(user: @user, organisation: @organisation)
    redirect_to_index
    flash[:success] = t(".user_removed")
  end

  private

  def set_user
    @user = users.find(params.require(:id))
  end

  def users
    @users = @organisation.users
  end

  def redirect_if_not_allowed
    unless policy(@user).destroy?
      redirect_to_index
      flash[:alert] = t(".you_cannot_perform_this_action")
    end
  end

  def user_params
    params.require(:user_invite_form)
          .permit(:first_name, :last_name, :email)
          .merge({ service: current_service, organisation: @organisation })
  end

  def user_form
    @user_form ||= UserInviteForm.new(user_params)
  end
end

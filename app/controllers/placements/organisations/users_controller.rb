class Placements::Organisations::UsersController < ApplicationController
  before_action :set_organisation

  def index
    users
  end

  def show
    @user = users.find(params.require(:id))
  end

  def new
    @user_form = params[:user_invite_form].present? ? user_form : UserInviteForm.new
  end

  def check
    render :new unless user_form.valid?
  end

  def create
    if user_form.invite
      redirect_to_index
      flash[:success] = t(".user_added")
    else
      render :new
    end
  end

  private

  def users
    @users = @organisation.users.order("LOWER(first_name)")
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

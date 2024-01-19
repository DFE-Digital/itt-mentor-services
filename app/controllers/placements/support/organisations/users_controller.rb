class Placements::Support::Organisations::UsersController < Placements::Support::ApplicationController
  before_action :set_organisation

  def index
    users
  end

  def show
    @user = users.find(params[:id]).becomes(Placements::User)
  end

  def new
    @user = params[:placements_user].present? ? user : Placements::User.new
  end

  def check
    if user.valid?
      @user = user.decorate
    else
      render :new
    end
  end

  def create
    if UserInviteService.call(user, @organisation, sign_in_url)
      redirect_to_index
      flash[:success] = t(".user_added")
    else
      render :new
    end
  end

  private

  def users
    @users = @organisation.users.placements
  end

  def user
    @user ||= Placements::User.new(user_params)
  end

  def user_params
    params.require(:placements_user).permit(:first_name, :last_name, :email)
  end
end

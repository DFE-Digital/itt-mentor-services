class Claims::Support::UsersController < Claims::Support::ApplicationController
  before_action :set_school

  def index
    @users = @school.users
  end

  def show
    @user = Claims::User.find(params.require(:id))
  end

  def new
    @user = Claims::User.new
  end

  def check
    if user.valid?
      @user = user.decorate
    else
      render :new
    end
  end

  def create
    if UserInviteService.call(user, @school, sign_in_url)
      redirect_to claims_support_school_users_path(@school)
      flash[:success] = "User added"
    else
      render :new
    end
  end

  private

  def set_school
    @school = Claims::School.find(params.require(:school_id))
  end

  def user
    @user ||= Claims::User.new(user_params)
  end

  def user_params
    params.require(:claims_user).permit(:first_name, :last_name, :email)
  end
end

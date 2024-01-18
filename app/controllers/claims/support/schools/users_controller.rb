class Claims::Support::Schools::UsersController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  def index
    @users = @school.users
  end

  def show
    @user = @school.users.find(params.require(:id))
  end

  def new
    @user = params[:claims_user].present? ? user : Claims::User.new
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

  def user
    @user ||= Claims::User.new(user_params)
  end

  def user_params
    params.require(:claims_user).permit(:first_name, :last_name, :email)
  end
end

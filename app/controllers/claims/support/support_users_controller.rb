class Claims::Support::SupportUsersController < Claims::Support::ApplicationController
  before_action :set_support_user, only: %i[show remove destroy]

  def index
    @support_users = Claims::SupportUser.order(created_at: :desc)
  end

  def new
    @support_user = if params[:support_user].present?
                      Claims::SupportUser.new(support_user_params)
                    else
                      Claims::SupportUser.new
                    end
  end

  def check
    @support_user = Claims::SupportUser.new(support_user_params)

    render :new unless @support_user.valid?
  end

  def create
    @support_user = Claims::SupportUser.new(support_user_params)

    if SupportUser::Invite.call(support_user: @support_user)
      redirect_to claims_support_support_users_path, flash: { success: t(".success") }
    else
      render :check
    end
  end

  def show; end

  def remove; end

  def destroy
    if SupportUser::Remove.call(support_user: @support_user)
      redirect_to claims_support_support_users_path, notice: t(".success")
    else
      render :remove, alert: t(".failure")
    end
  end

  private

  def support_user_params
    @support_user_params ||= params.require(:support_user).permit(:first_name, :last_name, :email)
  end

  def set_support_user
    @support_user = Claims::SupportUser.find(params.require(:id))
  end
end

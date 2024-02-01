class Placements::Support::SupportUsersController < Placements::Support::ApplicationController
  before_action :set_support_user, only: %i[show remove destroy]

  def index
    @support_users = Placements::SupportUser.order(created_at: :desc)
  end

  def new
    @support_user = if params[:support_user].present?
                      Placements::SupportUser.new(support_user_params)
                    else
                      Placements::SupportUser.new
                    end
  end

  def check
    @support_user = Placements::SupportUser.new(support_user_params)

    render :new unless @support_user.valid?
  end

  def create
    @support_user = Placements::SupportUser.new(support_user_params)

    if SupportUser::Invite.call(support_user: @support_user)
      redirect_to placements_support_support_users_path, flash: { success: t(".success") }
    else
      render :check
    end
  end

  def show; end

  def remove; end

  def destroy
    authorize @support_user

    SupportUser::Remove.call(support_user: @support_user)
    redirect_to claims_support_support_users_path, flash: { success: t(".success") }
  end

  private

  def support_user_params
    @support_user_params ||= params.require(:support_user).permit(:first_name, :last_name, :email)
  end

  def set_support_user
    @support_user = Placements::SupportUser.find(params.require(:id))
  end
end

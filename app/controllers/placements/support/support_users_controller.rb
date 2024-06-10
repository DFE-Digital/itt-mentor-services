class Placements::Support::SupportUsersController < Placements::Support::ApplicationController
  before_action :set_support_user, only: %i[show remove destroy]
  before_action :authorize_support_user, only: %i[remove destroy]

  def index
    @support_users = Placements::SupportUser.order_by_full_name
  end

  def new
    @support_user_form = params[:support_user].present? ? support_user_form : SupportUserInviteForm.new
  end

  def check
    render :new unless support_user_form.valid?
  end

  def create
    support_user_form.save!
    SupportUser::Invite.call(support_user: support_user_form.support_user)
    redirect_to placements_support_support_users_path, flash: { success: t(".success") }
  end

  def show; end

  def remove; end

  def destroy
    SupportUser::Remove.call(support_user: @support_user)
    redirect_to placements_support_support_users_path, flash: { success: t(".success") }
  end

  private

  def support_user_params
    @support_user_params ||= params.require(:support_user)
      .permit(:first_name, :last_name, :email)
      .merge({ service: current_service })
  end

  def set_support_user
    @support_user = Placements::SupportUser.find(params.require(:id))
  end

  def support_user_form
    @support_user_form ||= SupportUserInviteForm.new(support_user_params)
  end

  def authorize_support_user
    authorize @support_user
  end
end

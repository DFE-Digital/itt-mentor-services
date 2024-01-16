class Claims::Support::SupportUsersController < Claims::Support::ApplicationController
  before_action :set_support_user, only: %i[show]

  def index
    @support_users = Claims::SupportUser.order(created_at: :desc)
  end

  def show; end

  private

  def set_support_user
    @support_user = Claims::SupportUser.find(params.require(:id))
  end
end

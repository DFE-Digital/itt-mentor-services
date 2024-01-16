class Claims::Support::SupportUsersController < Claims::Support::ApplicationController
  def index
    @support_users = Claims::SupportUser.order(created_at: :desc)
  end
end

class Claims::Support::Claims::ActivityLogPolicy < Claims::ApplicationPolicy
  def read?
    user.support_user?
  end
end

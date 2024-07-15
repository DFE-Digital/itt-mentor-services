class Claims::ClaimWindowPolicy < Claims::ApplicationPolicy
  def read?
    user.support_user?
  end

  def new_check?
    new?
  end

  def create?
    user.support_user?
  end

  def edit_check?
    edit?
  end

  def update?
    user.support_user? && !record.past?
  end

  def destroy?
    user.support_user? && !record.past?
  end
end

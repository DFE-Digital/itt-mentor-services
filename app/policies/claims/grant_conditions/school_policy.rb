class Claims::GrantConditions::SchoolPolicy < Claims::ApplicationPolicy
  def show?
    record.users.include?(user)
  end

  def update?
    record.users.include?(user)
  end
end

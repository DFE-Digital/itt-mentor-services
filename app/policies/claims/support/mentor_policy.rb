class Claims::Support::MentorPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def destroy?
    true
  end
end

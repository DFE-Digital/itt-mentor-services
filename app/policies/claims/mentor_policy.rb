class Claims::MentorPolicy < Claims::ApplicationPolicy
  def destroy?
    true
  end
end

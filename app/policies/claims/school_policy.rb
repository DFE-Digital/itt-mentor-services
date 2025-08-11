class Claims::SchoolPolicy < Claims::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.joins(:users).where(users: { id: user })
    end
  end
end

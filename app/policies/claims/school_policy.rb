class Claims::SchoolPolicy < Claims::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:users).where(users: { id: user })
    end
  end
end

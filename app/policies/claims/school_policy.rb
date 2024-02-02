class Claims::SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.support_user?
        scope.all
      else
        scope.joins(:users).where(users: { id: user })
      end
    end
  end
end

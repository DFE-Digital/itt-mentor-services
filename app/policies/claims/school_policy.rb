class Claims::SchoolPolicy < Claims::ApplicationPolicy
  def school_options?
    true
  end

  def check_school_option?
    true
  end

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

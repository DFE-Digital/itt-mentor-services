class Claims::SchoolPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def school_options?
    true
  end

  def check_school_option?
    true
  end

  def remove_grant_conditions_acceptance_check?
    user != record && user.support_user?
  end

  def remove_grant_conditions_acceptance?
    remove_grant_conditions_acceptance_check?
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

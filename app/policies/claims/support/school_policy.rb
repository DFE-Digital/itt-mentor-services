class Claims::Support::SchoolPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def remove_grant_conditions_acceptance_check?
    user != record && user.support_user?
  end

  def remove_grant_conditions_acceptance?
    remove_grant_conditions_acceptance_check?
  end

  def search?
    user.support_user?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

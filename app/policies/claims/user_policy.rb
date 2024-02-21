class Claims::UserPolicy < ApplicationPolicy
  def destroy?
    user != record
  end
end

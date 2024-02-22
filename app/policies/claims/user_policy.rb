class Claims::UserPolicy < ApplicationPolicy
  def destroy?
    user != record
  end

  def remove?
    destroy?
  end
end

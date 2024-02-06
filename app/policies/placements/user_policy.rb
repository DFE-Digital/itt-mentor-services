class Placements::UserPolicy < ApplicationPolicy
  def destroy?
    user != record
  end
end

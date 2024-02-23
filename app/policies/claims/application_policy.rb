class Claims::ApplicationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def check?
    new?
  end

  def edit?
    update?
  end

  def remove?
    destroy?
  end
end

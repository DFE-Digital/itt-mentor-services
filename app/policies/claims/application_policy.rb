class Claims::ApplicationPolicy < ApplicationPolicy
  def read?
    true
  end

  def index?
    read?
  end

  def show?
    read?
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

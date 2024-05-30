class PlacementPolicy < ApplicationPolicy
  def new?
    record.school.school_contact.present?
  end
  alias_method :add_phase?, :new?
  alias_method :add_subject?, :new?
  alias_method :add_additional_subjects?, :new?
  alias_method :add_year_group?, :new?
  alias_method :add_mentors?, :new?
  alias_method :check_your_answers?, :new?

  def update?
    record.school.school_contact.present?
  end
  alias_method :edit_provider?, :update?
  alias_method :edit_mentors?, :update?
end

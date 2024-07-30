class PlacementPolicy < ApplicationPolicy
  def new?
    record.school.school_contact.present?
  end

  def destroy?
    record.provider.blank?
  end

  # Actions in Placements::Schools::PlacementsController
  alias_method :edit_provider?, :new?
  alias_method :edit_mentors?, :new?
  alias_method :edit_year_group?, :new?
  alias_method :update?, :new?

  # This permission represents the entire "Add placement" journey.
  # It's not a traditional CRUD/resourceful controller, but the end
  # result is a new Placement being created.
  # Placements::Schools::Placements::AddPlacementController
  alias_method :add_placement_journey?, :new?
end

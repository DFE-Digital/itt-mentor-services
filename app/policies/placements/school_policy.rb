class Placements::SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.schools)
    end
  end

  def edit_potential_placements?
    record.potential_placement_details.present? &&
      record.current_hosting_interest(
        academic_year: user.selected_academic_year,
      ).interested?
  end
end

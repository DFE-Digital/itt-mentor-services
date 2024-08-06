class Placements::Support::Schools::PlacementsController < Placements::Schools::PlacementsController
  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def edit_attribute_path(attribute)
    new_edit_placement_placements_support_school_placement_path(@school, @placement, step: attribute)
  end

  def add_provider_path
    placements_support_school_partner_providers_path
  end

  def add_mentor_path
    placements_support_school_mentors_path
  end

  def index_path
    placements_support_school_placements_path(@school)
  end
end

class Placements::Support::Schools::Placements::EditPlacementController < Placements::Schools::Placements::EditPlacementController
  private

  def set_school
    school_id = params.require(:school_id)
    @school = Placements::School.find(school_id)
  end

  def after_update_placement_path
    placements_support_school_placement_path(@school, @placement)
  end

  def step_path(step)
    edit_placement_placements_support_school_placement_path(state_key:, step:)
  end

  def back_link_path
    placements_support_school_placement_path(@school, @placement)
  end

  def add_mentor_path
    new_add_mentor_placements_support_school_mentors_path
  end

  def unlisted_provider_path
    placements_support_school_partner_providers_path(@school)
  end
end

class Placements::Support::Schools::Placements::AddPlacementController < Placements::Schools::Placements::AddPlacementController
  private

  def set_school
    school_id = params.require(:school_id)
    @school = Placements::School.find(school_id)
  end

  def update_path(school)
    placements_support_school_placements_path(school)
  end

  def step_path(step)
    add_placement_placements_support_school_placements_path(step:)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      placements_support_school_placements_path(@school)
    end
  end
end

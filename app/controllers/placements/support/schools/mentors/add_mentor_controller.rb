class Placements::Support::Schools::Mentors::AddMentorController < Placements::Schools::Mentors::AddMentorController
  def change_mentor_details_path
    add_mentor_placements_support_school_mentors_path(step: :mentor)
  end

  private

  def set_school
    @school = Placements::School.find(params.require(:school_id))
  end

  def step_path(step)
    add_mentor_placements_support_school_mentors_path(step:)
  end

  def index_path
    placements_support_school_mentors_path(@school)
  end
end

class Placements::Support::Schools::MentorsController < Placements::Schools::MentorsController
  private

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def redirect_to_index_path
    redirect_to placements_support_school_mentors_path(@school)
  end
end
